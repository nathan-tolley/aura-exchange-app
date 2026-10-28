import 'dart:convert';
import 'dart:typed_data';

import 'package:aura_exchange/api/client.dart';
import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/data/uploads.dart';
import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_photo_tile.dart';
import 'package:aura_exchange/features/events/file_sheet.dart';
import 'package:aura_exchange/features/events/receipts.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:aura_exchange/router.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/api_json.dart';
import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// Photo receipts when filing (SCREENS.md #11): each photo uploads as it's
/// added (`POST /uploads`, then the bytes to the signed URL), and the
/// filing carries the ones that made it.
class FakePhotos implements PhotoSource {
  int libraryLimit = -1;
  int libraryCount = 1;
  bool cameraOff = false;

  /// A 1×1 PNG, so the sheet can draw it.
  static final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );

  static PickedPhoto photo(int n) =>
      PickedPhoto(bytes: Uint8List.fromList(png), contentType: 'image/jpeg');

  @override
  Future<List<PickedPhoto>> library({required int limit}) async {
    libraryLimit = limit;
    return [for (var i = 0; i < libraryCount; i++) photo(i)];
  }

  @override
  Future<PickedPhoto?> camera() async {
    if (cameraOff) throw const CameraDenied();
    return photo(9);
  }
}

void main() {
  final now = DateTime.utc(2026, 10, 24, 10, 41);
  late FakeAdapter http;
  late FakePhotos photos;
  late ProviderContainer container;
  var uploads = 0;
  var storageFails = false;
  var expiresAt = now.add(const Duration(minutes: 15));

  Map<String, Object?> upload() => {
    'receiptId': '99999999-0000-4000-8000-00000000000${++uploads}',
    'uploadUrl': 'https://storage.test/r/$uploads?sig=abc',
    'method': 'PUT',
    'headers': {'x-amz-meta-exchange': testExchangeId},
    'expiresAt': expiresAt.toIso8601String(),
  };
  bool isStorage(RequestOptions r) => r.uri.host == 'storage.test';
  List<RequestOptions> puts() => http.requests.where(isStorage).toList();

  ResponseBody answer(RequestOptions r) {
    if (isStorage(r)) {
      return storageFails ? offline(r) : ResponseBody.fromString('', 200);
    }
    return switch (r.path) {
      '/uploads' => jsonBody(201, upload()),
      _ => errorBody(404, 'NOT_FOUND'),
    };
  }

  setUp(() {
    uploads = 0;
    storageFails = false;
    expiresAt = now.add(const Duration(minutes: 15));
    photos = FakePhotos();
    http = FakeAdapter(answer);
    container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: now,
      overrides: [photoSourceProvider.overrideWithValue(photos)],
    );
  });

  tearDown(() => container.dispose());

  /// Keeps the filing's receipts alive, as the open sheet does.
  void withPhotos() => container.listen(receiptsProvider, (_, _) {});

  Receipts receipts() => container.read(receiptsProvider.notifier);
  List<ReceiptDraft> drafts() => container.read(receiptsProvider);

  group('uploads', () {
    test('a photo asks for a URL, then sends its bytes there alone', () async {
      withPhotos();
      expect(await receipts().fromLibrary(), AddOutcome.added);
      await pumpEventQueue();

      final ask = http.to('/uploads').single;
      expect(ask.method, 'POST');
      expect(ask.headers['Idempotency-Key'], isNotNull);
      // As it goes on the wire.
      expect(jsonDecode(jsonEncode(ask.data)), {
        'contentType': 'image/jpeg',
        'byteSize': FakePhotos.png.length,
      });

      final put = puts().single;
      expect(put.method, 'PUT');
      expect(put.uri.toString(), 'https://storage.test/r/1?sig=abc');
      // The signed URL is the only credential: nothing of the app's.
      expect(put.headers['Authorization'], isNull);
      expect(put.headers['X-App-Build'], isNull);
      expect(put.headers['x-amz-meta-exchange'], testExchangeId);
      expect(put.headers['content-type'], 'image/jpeg');

      expect(drafts().single.status, AuraPhotoStatus.ready);
      expect(receipts().receiptIds, ['99999999-0000-4000-8000-000000000001']);
    });

    test('the library offers only the room left, up to four', () async {
      withPhotos();
      photos.libraryCount = 3;
      await receipts().fromLibrary();
      expect(photos.libraryLimit, 4);
      await receipts().fromLibrary();
      expect(photos.libraryLimit, 1);
      expect(drafts(), hasLength(4));
      expect(await receipts().fromLibrary(), AddOutcome.nothing);
    });

    test('Retry after a failed send reuses the URL it was given', () async {
      withPhotos();
      storageFails = true;
      await receipts().fromLibrary();
      await pumpEventQueue();
      final failed = drafts().single;
      expect(failed.status, AuraPhotoStatus.failed);
      expect(failed.problem?.code, ApiError.appOffline);
      expect(receipts().receiptIds, isEmpty);

      storageFails = false;
      receipts().retry(failed.id);
      expect(drafts().single.status, AuraPhotoStatus.uploading);
      await pumpEventQueue();
      expect(http.to('/uploads'), hasLength(1));
      expect(puts(), hasLength(2));
      expect(drafts().single.status, AuraPhotoStatus.ready);
    });

    test('an expired URL is asked for again, with a new key', () async {
      withPhotos();
      storageFails = true;
      expiresAt = now.subtract(const Duration(minutes: 1));
      await receipts().fromLibrary();
      await pumpEventQueue();
      storageFails = false;
      expiresAt = now.add(const Duration(minutes: 15));
      receipts().retry(drafts().single.id);
      await pumpEventQueue();
      final asks = http.to('/uploads');
      expect(asks, hasLength(2));
      expect(
        asks[1].headers['Idempotency-Key'],
        isNot(asks[0].headers['Idempotency-Key']),
      );
      expect(receipts().receiptIds, ['99999999-0000-4000-8000-000000000002']);
    });

    test('a removed photo never goes with the filing', () async {
      withPhotos();
      photos.libraryCount = 2;
      await receipts().fromLibrary();
      receipts().remove(drafts().first.id);
      await pumpEventQueue();
      expect(drafts(), hasLength(1));
      expect(receipts().receiptIds, hasLength(1));
    });

    test('the camera, and the camera turned off', () async {
      withPhotos();
      expect(await receipts().fromCamera(), AddOutcome.added);
      photos.cameraOff = true;
      expect(await receipts().fromCamera(), AddOutcome.cameraOff);
      expect(drafts(), hasLength(1));
    });

    test('content types come from the file', () {
      expect(contentTypeOf('image/png', 'a.png'), 'image/png');
      expect(contentTypeOf(null, 'IMG_0001.HEIC'), 'image/heic');
      expect(contentTypeOf(null, 'image_picker_123.jpg'), 'image/jpeg');
      expect(contentTypeOf('image/gif', 'a.gif'), 'image/jpeg');
    });
  });

  group('model', () {
    ReceiptDraft draft(int id, AuraPhotoStatus status, {ApiError? problem}) =>
        ReceiptDraft(
          id: id,
          photo: FakePhotos.photo(id),
          key: IdempotencyKey(),
          status: status,
          problem: problem,
        );

    test('help, uploading, full', () {
      expect(receiptsModel(const []).note, receiptsHelp(4));
      expect(receiptsModel(const []).canAdd, isTrue);
      final up = receiptsModel([draft(0, AuraPhotoStatus.uploading)]);
      expect(up.note, uploadingPhotos(1));
      expect(up.blocksFiling, waitForReceipts);
      final full = receiptsModel([
        for (var i = 0; i < 4; i++) draft(i, AuraPhotoStatus.ready),
      ]);
      expect(full.canAdd, isFalse);
      expect(full.note, receiptsFull(4));
      expect(full.blocksFiling, isNull);
      expect(full.tiles.last.label, 'Receipt 4');
    });

    test('a failed one says what to do, and holds the filing', () {
      final m = receiptsModel([
        draft(0, AuraPhotoStatus.ready),
        draft(1, AuraPhotoStatus.failed, problem: const ApiError.offline()),
      ]);
      expect(m.note, receiptOffline);
      expect(m.noteTone, AuraTone.down);
      expect(m.blocksFiling, fixReceiptsToFile);
      expect(m.tiles[1].label, contains("didn't upload"));
    });

    test('File is off while a photo uploads, and says why', () {
      final m = fileModel(
        subjects: const [],
        subject: const FileSubject(id: 'j', ticker: r'$JAKE', name: 'Jake'),
        hasText: true,
        filing: false,
        problem: null,
        receipts: [draft(0, AuraPhotoStatus.uploading)],
      );
      expect(m.canFile, isFalse);
      expect(m.note, waitForReceipts);
    });
  });

  group('the sheet', () {
    const jake = '11111111-0000-4000-8000-000000000002';
    Map<String, Object?>? filed;

    ResponseBody app(RequestOptions r) {
      if (isStorage(r)) return ResponseBody.fromString('', 200);
      return switch (r.path) {
        '/me' => jsonBody(200, meJson([membershipJson()])),
        '/exchanges/$testExchangeId' => jsonBody(
          200,
          exchangeJson(listed: 4, members: 5, meListed: true),
        ),
        '/exchanges/$testExchangeId/market' => jsonBody(
          200,
          marketJson(
            listings: [
              {...listingJson(r'$JAKE', 'Jake', price: '101.90'), 'id': jake},
              listingJson(r'$NATE', 'Nathan', mine: true),
            ],
          ),
        ),
        '/exchanges/$testExchangeId/portfolio' => jsonBody(
          200,
          exampleJson('portfolio'),
        ),
        '/exchanges/$testExchangeId/tape' => jsonBody(200, {
          'items': <Object?>[],
          'nextCursor': null,
        }),
        '/uploads' => jsonBody(201, upload()),
        '/events' => () {
          filed = r.data as Map<String, Object?>;
          return errorBody(404, 'NOT_FOUND');
        }(),
        _ => errorBody(404, 'NOT_FOUND'),
      };
    }

    testWidgets('add a screenshot, then file with it', (tester) async {
      filed = null;
      http.handler = app;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const AuraApp()),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).go(Routes.fileAbout(jake));
      await tester.pumpAndSettle();
      expect(find.byType(FileSheet), findsOneWidget);
      expect(find.text(receiptsHelp(4)), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(addAReceipt));
      await tester.pumpAndSettle();
      expect(find.text(chooseFromPhotos), findsOneWidget);
      await tester.tap(find.text(chooseFromPhotos));
      await tester.pumpAndSettle();
      expect(find.text(chooseFromPhotos), findsNothing);
      expect(find.bySemanticsLabel('Receipt 1'), findsOneWidget);

      await tester.enterText(
        find.byType(EditableText),
        'Jake replied "who is this" to his own mum.',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(fileIt));
      await tester.pumpAndSettle();
      expect(filed?['receiptIds'], ['99999999-0000-4000-8000-000000000001']);
      expect(filed?['subjectListingId'], jake);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      container = testContainer(http: http, sockets: <FakeSocket>[], now: now);
    });
  });
}
