import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/repositories.dart';
import '../../l10n/strings.dart';

/// Where a trade is (SCREENS.md #9, #10): what you're setting up, the quote
/// it's priced at, and what came of it.
@immutable
class TradeFlowState {
  const TradeFlowState({
    required this.side,
    required this.orderType,
    this.quantity = 1,
    this.price = '',
    this.quote,
    this.quoting = false,
    this.problem,
    this.stale,
    this.busy = false,
    this.filled,
    this.order,
    this.canceled = false,
  });

  final Side side;

  /// [orderMarket], [orderLimit] or [orderStop].
  final String orderType;
  final int quantity;

  /// A limit or stop's price as typed.
  final String price;

  /// The price this trade would go through at, for 15 s.
  final Quote? quote;
  final bool quoting;

  /// Why the last quote, trade or order didn't go through.
  final ApiError? problem;

  /// The `QUOTE_STALE` that led to [quote] being a requote (W06).
  final ApiError? stale;

  /// A trade or order is on its way.
  final bool busy;
  final Trade? filled;
  final Order? order;
  final bool canceled;

  TradeFlowState copyWith({
    Side? side,
    String? orderType,
    int? quantity,
    String? price,
    Quote? Function()? quote,
    bool? quoting,
    ApiError? Function()? problem,
    ApiError? Function()? stale,
    bool? busy,
    Trade? filled,
    Order? order,
    bool? canceled,
  }) => TradeFlowState(
    side: side ?? this.side,
    orderType: orderType ?? this.orderType,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    quote: quote == null ? this.quote : quote(),
    quoting: quoting ?? this.quoting,
    problem: problem == null ? this.problem : problem(),
    stale: stale == null ? this.stale : stale(),
    busy: busy ?? this.busy,
    filled: filled ?? this.filled,
    order: order ?? this.order,
    canceled: canceled ?? this.canceled,
  );

  /// The typed price, if it's a usable one.
  Decimal? get priceValue {
    final p = Decimal.tryParse(price.trim());
    return p == null || p <= Decimal.zero ? null : p;
  }
}

/// What the trade sheet is for: a listing, a side, and whether the market
/// takes market orders right now.
typedef TradeArgs = ({String listingId, Side side, bool marketOpen});

final tradeFlowProvider = NotifierProvider.autoDispose
    .family<TradeFlow, TradeFlowState, TradeArgs>(TradeFlow.new);

/// Prices, trades and places orders. Keys: each quote request has its own;
/// the trade's key is made when the slide lands and reused by Retry; a
/// requote's slide is a new commit with a new key; an order's key is made
/// when its slide lands.
class TradeFlow extends Notifier<TradeFlowState> {
  TradeFlow(this.args);

  final TradeArgs args;

  Timer? _requoteSoon;
  Timer? _expiry;
  IdempotencyKey? _tradeKey;
  String? _tradeKeyFor;
  IdempotencyKey? _orderKey;
  int _quoteSeq = 0;

  @override
  TradeFlowState build() {
    ref.onDispose(() {
      _requoteSoon?.cancel();
      _expiry?.cancel();
    });
    final market =
        args.marketOpen || args.side == Side.short || args.side == Side.cover;
    final start = TradeFlowState(
      side: args.side,
      orderType: market ? orderMarket : orderLimit,
    );
    if (market) Future.microtask(_quote);
    return start;
  }

  TradingRepository get _repo => ref.read(tradingRepositoryProvider);

  void setQuantity(int quantity) {
    if (quantity < 1 || quantity == state.quantity) return;
    state = state.copyWith(quantity: quantity, problem: () => null);
    if (state.orderType == orderMarket) {
      _requoteSoon?.cancel();
      _requoteSoon = Timer(const Duration(milliseconds: 300), _quote);
    }
  }

  void setOrderType(String type) {
    if (type == state.orderType) return;
    state = state.copyWith(orderType: type, problem: () => null);
    if (type == orderMarket) unawaited(_quote());
  }

  void setPrice(String price) =>
      state = state.copyWith(price: price, problem: () => null);

  /// A refused quote's fix: "Buy 18" sets the quantity the server allows.
  void applyFix() {
    final max = int.tryParse(
      state.problem?.params['maxQuantity']?.split('.').first ?? '',
    );
    if (max != null && max > 0) setQuantity(max);
  }

  /// Prices the trade; replaces the quote shown. Only the latest request
  /// counts.
  Future<void> _quote({String? previousQuoteId}) async {
    final seq = ++_quoteSeq;
    _expiry?.cancel();
    state = state.copyWith(quoting: true);
    try {
      final quote = await _repo.quote(
        QuoteRequest(
          listingId: args.listingId,
          side: state.side,
          quantity: '${state.quantity}',
          previousQuoteId: previousQuoteId,
        ),
        IdempotencyKey(),
      );
      if (!ref.mounted || seq != _quoteSeq) return;
      state = state.copyWith(
        quote: () => quote,
        quoting: false,
        problem: () => null,
      );
      _expireAt(quote.expiresAt);
    } on ApiError catch (e) {
      if (!ref.mounted || seq != _quoteSeq) return;
      state = state.copyWith(
        quote: () => null,
        quoting: false,
        problem: () => e,
      );
    }
  }

  /// When a quote runs out with nothing in flight, a new one replaces it;
  /// the countdown never sits at 0:00.
  void _expireAt(DateTime at) {
    final left = at.difference(DateTime.now().toUtc());
    _expiry = Timer(left.isNegative ? Duration.zero : left, () {
      if (!ref.mounted || state.busy || state.stale != null) return;
      unawaited(_quote());
    });
  }

  /// The slide landed on [quote]: trade it.
  Future<Trade?> trade() async {
    final quote = state.quote;
    if (quote == null || state.busy) return null;
    if (_tradeKeyFor != quote.id) {
      _tradeKey = IdempotencyKey();
      _tradeKeyFor = quote.id;
    }
    _expiry?.cancel();
    state = state.copyWith(busy: true, problem: () => null);
    try {
      final filled = await _repo.trade(quote.id, _tradeKey!);
      if (!ref.mounted) return null;
      unawaited(HapticFeedback.mediumImpact());
      state = state.copyWith(busy: false, filled: filled, stale: () => null);
      return filled;
    } on ApiError catch (e) {
      if (!ref.mounted) return null;
      if (e.errorCode == ErrorCode.quoteStale) {
        // W06: price it again, showing the difference.
        state = state.copyWith(busy: false, stale: () => e);
        await _quote(previousQuoteId: quote.id);
        return null;
      }
      unawaited(HapticFeedback.heavyImpact());
      state = state.copyWith(busy: false, problem: () => e);
      return null;
    }
  }

  /// "Don't buy" on a requote: back to the ticket with the new price.
  void declineRequote() => state = state.copyWith(stale: () => null);

  /// The slide landed on a limit or stop order: place it.
  Future<Order?> placeOrder({String? positionId}) async {
    final price = state.priceValue;
    if (price == null || state.busy) return null;
    _orderKey ??= IdempotencyKey();
    state = state.copyWith(busy: true, problem: () => null);
    try {
      final order = await _repo.placeOrder(
        OrderCreate(
          listingId: args.listingId,
          type: switch (state.orderType) {
            orderStop => OrderType.stopLoss,
            _ when state.side == Side.sell => OrderType.limitSell,
            _ => OrderType.limitBuy,
          },
          quantity: '${state.quantity}',
          triggerPrice: price.toStringAsFixed(2),
          positionId: state.orderType == orderStop ? positionId : null,
        ),
        _orderKey!,
      );
      if (!ref.mounted) return null;
      _orderKey = null;
      unawaited(HapticFeedback.mediumImpact());
      state = state.copyWith(busy: false, order: order);
      return order;
    } on ApiError catch (e) {
      if (!ref.mounted) return null;
      state = state.copyWith(busy: false, problem: () => e);
      return null;
    }
  }

  /// "Set a stop-loss" after a buy: a stop on what you now hold.
  void toStopLoss() => state = TradeFlowState(
    side: Side.sell,
    orderType: orderStop,
    quantity: state.quantity,
  );

  /// Cancels the resting order just placed.
  Future<void> cancelOrder() async {
    final order = state.order;
    if (order == null || state.busy) return;
    state = state.copyWith(busy: true, problem: () => null);
    try {
      await _repo.cancelOrder(order.id, IdempotencyKey());
      if (ref.mounted) state = state.copyWith(busy: false, canceled: true);
    } on ApiError catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, problem: () => e);
    }
  }

  /// The banner's Retry: the same action again (the same keys).
  Future<void> retry({String? positionId}) async {
    if (state.orderType != orderMarket) {
      await placeOrder(positionId: positionId);
    } else if (state.quote != null && state.problem != null) {
      await trade();
    } else {
      await _quote();
    }
  }
}
