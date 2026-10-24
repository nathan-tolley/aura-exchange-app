/* @ds-bundle: {"format":4,"namespace":"Aura","components":[{"name":"Money"},{"name":"PriceChange"},{"name":"Avatar"},{"name":"Tag"},{"name":"StatusChip"},{"name":"Countdown"},{"name":"Icon"},{"name":"IconButton"},{"name":"Button"},{"name":"SlideToConfirm"},{"name":"SegmentedControl"},{"name":"Tabs"},{"name":"SearchField"},{"name":"SectionHeader"},{"name":"StatCard"},{"name":"RangeBar"},{"name":"Sparkline"},{"name":"StockRow"},{"name":"HeroCard"},{"name":"ActionButton"},{"name":"NavCard"},{"name":"NavRow"},{"name":"QuoteCard"},{"name":"ImpactDisc"},{"name":"ChartTooltip"},{"name":"Banner"},{"name":"EmptyState"},{"name":"Toast"},{"name":"Sheet"},{"name":"TabBar"},{"name":"Tape"},{"name":"Receipt"},{"name":"Stepper"}]} */
(function () {
  /* React is read at render time, so the bundle can load before or after it. */
  function h() { return window.React.createElement.apply(window.React, arguments); }

  function cx() { return Array.prototype.filter.call(arguments, Boolean).join(' '); }
  var MINUS = '−';
  function fmt(n) {
    return Math.abs(Number(n)).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
  function signed(n, suffix) {
    var v = Number(n);
    return (v > 0 ? '+' : v < 0 ? MINUS : '') + fmt(v) + (suffix || '');
  }
  function trendOf(n) { var v = Number(n); return v > 0 ? 'up' : v < 0 ? 'down' : 'flat'; }

  /* Icons: 24-unit stroke paths. On iOS these are SF Symbols; names map in the README. */
  var ICONS = {
    back: 'M19 12H5 M11 6l-6 6 6 6',
    close: 'M6 6l12 12 M18 6L6 18',
    chevron: 'M9 5l7 7-7 7',
    arrow: 'M4.5 12h15 M14 6.5l5.5 5.5-5.5 5.5',
    search: 'M10.5 4.5a6 6 0 1 1 0 12a6 6 0 1 1 0-12z M15 15l5 5',
    bell: 'M12 3.5c-3.3 0-5 2.4-5 5v4l-1.8 3h13.6l-1.8-3v-4c0-2.6-1.7-5-5-5z M9.8 18.5a2.3 2.3 0 0 0 4.4 0',
    star: 'M12 3.5l2.6 5.3 5.9.8-4.3 4.1 1 5.8L12 16.8l-5.2 2.7 1-5.8-4.3-4.1 5.9-.8z',
    alarm: 'M12 7.5v5l2.5 2 M12 20a7 7 0 1 1 0-14a7 7 0 1 1 0 14z M4 6.5L7 4 M20 6.5L17 4',
    trade: 'M8 4.5v15 M8 4.5L4.5 8 M8 4.5L11.5 8 M16 19.5v-15 M16 19.5l-3.5-3.5 M16 19.5l3.5-3.5',
    file: 'M14 3.5H7a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8.5z M14 3.5v5h5 M12 11.5v6 M9 14.5h6',
    short: 'M3.5 7l6 6 4-4 7 7 M20.5 16h-5 M20.5 16v-5',
    vote: 'M5.5 4.5h13a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1h-13a1 1 0 0 1-1-1v-13a1 1 0 0 1 1-1z M8.5 12l2.5 2.5 4.5-5',
    home: 'M4.5 10.5L12 4.5l7.5 6v8a1.5 1.5 0 0 1-1.5 1.5h-3.5v-5.5h-5V20H6a1.5 1.5 0 0 1-1.5-1.5z',
    market: 'M5.5 19v-8 M12 19V5 M18.5 19v-5',
    tape: 'M4.5 5.5h15v13h-15z M8 10h8 M8 14h5',
    portfolio: 'M12 3.5a8.5 8.5 0 1 0 8.5 8.5H12z M14 2.5a8 8 0 0 1 7.5 7.5H14z',
    you: 'M12 4.5a3.8 3.8 0 1 1 0 7.6a3.8 3.8 0 1 1 0-7.6z M4.5 20c.6-4 3.8-6 7.5-6s6.9 2 7.5 6',
    plus: 'M12 5v14 M5 12h14',
    minus: 'M5 12h14',
    eyeOff: 'M3 12c2.6-4.6 15.4-4.6 18 0c-2.6 4.6-15.4 4.6-18 0z M12 9.5a2.5 2.5 0 1 1 0 5a2.5 2.5 0 1 1 0-5z M4.5 19.5l15-15',
    wifiOff: 'M3.5 9c2.4-2.2 5.3-3.3 8.5-3.3 M20.5 9a12 12 0 0 0-3.4-2.2 M6.5 12.5c1.5-1.3 3.4-2 5.5-2 M10 16a3 3 0 0 1 4 0 M12 19.5h.01 M4 4l16 16',
    clock: 'M12 4a8 8 0 1 1 0 16a8 8 0 1 1 0-16z M12 8v4.5l3 2',
    alert: 'M12 4l9 16H3z M12 10v4.5 M12 17.5h.01',
    chat: 'M4.5 5.5h15v10h-8l-4.5 3.5v-3.5h-2.5z',
    hide: 'M3 12c2.6-4.6 15.4-4.6 18 0c-2.6 4.6-15.4 4.6-18 0z M4.5 19.5l15-15',
    gavel: 'M12 3v18 M5 7h14 M5 7l-2.5 6h5z M19 7l-2.5 6h5z M8 21h8',
    shield: 'M12 3.5l7 3v5c0 4.3-3 7.6-7 9c-4-1.4-7-4.7-7-9v-5z',
    filter: 'M4.5 8h15 M16 4.5L19.5 8 16 11.5 M19.5 16h-15 M8 12.5L4.5 16 8 19.5',
    expand: 'M14 4.5h5.5V10 M19.5 4.5L13.5 10.5 M10 19.5H4.5V14 M4.5 19.5l6-6',
    line: 'M3.5 16.5l5.5-6 4 3.5 7.5-8',
    candles: 'M7.5 4v3 M7.5 17v3 M5.5 7h4v10h-4z M16.5 3v3 M16.5 14v4 M14.5 6h4v8h-4z',
    bolt: 'M13 3L5 13.5h6L10 21l8-10.5h-6z',
    trophy: 'M8 4.5h8v5a4 4 0 0 1-8 0z M8 6.5H5v1.5a3 3 0 0 0 3 3 M16 6.5h3v1.5a3 3 0 0 1-3 3 M12 13.5v3.5 M8.5 20h7',
    lock: 'M6.5 10.5h11v9h-11z M8.5 10.5V8a3.5 3.5 0 0 1 7 0v2.5'
  };

  function Icon(p) {
    var size = p.size || 20;
    var d = ICONS[p.name] || ICONS.chevron;
    var filled = p.filled;
    return h('svg', { width: size, height: size, viewBox: '0 0 24 24', 'aria-hidden': 'true', className: cx('ax-icon', p.className) },
      h('path', { d: d, fill: filled ? 'currentColor' : 'none', stroke: filled ? 'none' : 'currentColor', strokeWidth: p.weight || 1.7, strokeLinecap: 'round', strokeLinejoin: 'round' }));
  }

  function Money(p) {
    var v = fmt(p.value);
    var dot = v.lastIndexOf('.');
    return h('span', { className: cx('ax-money', p.size && 'ax-money-' + p.size, p.className) },
      (p.approx ? '≈ ' : ''), p.currency === false ? null : h('span', { className: 'ax-cur' }, 'A$'), v.slice(0, dot),
      h('span', { className: 'ax-cents' }, v.slice(dot)));
  }

  function PriceChange(p) {
    var t = trendOf(p.pct != null ? p.pct : p.abs);
    var arrow = t === 'up' ? '↑ ' : t === 'down' ? '↓ ' : '';
    var parts = [];
    if (p.abs != null) parts.push(signed(p.abs));
    if (p.pct != null) parts.push(p.abs != null ? '(' + signed(p.pct, '%') + ')' : signed(p.pct, '%'));
    var label = (t === 'up' ? 'Up ' : t === 'down' ? 'Down ' : 'Unchanged ') + parts.join(' ');
    return h('span', { className: cx('ax-change', 'ax-' + t, p.chip && 'ax-change-chip', p.size && 'ax-change-' + p.size), 'aria-label': label + (p.period ? ' ' + p.period : '') },
      arrow + parts.join(' ') + (p.period ? ' ' + p.period : ''));
  }

  function Avatar(p) {
    var size = p.size || 40;
    return h('span', { className: cx('ax-avatar', 'ax-avatar-' + (p.trend || 'flat')), style: { width: size, height: size, fontSize: Math.round(size * 0.4) }, 'aria-hidden': 'true' }, p.initial);
  }

  function Tag(p) { return h('span', { className: cx('ax-tag', p.tone && 'ax-tag-' + p.tone) }, p.children); }

  var STATUS = {
    open: ['up', 'Market open', true], pre: ['warn', 'Pre-market', true], after: ['warn', 'After hours', true],
    closed: ['neutral', 'Closed', true], halted: ['warn', 'Halted', true], delayed: ['warn', 'Delayed', true],
    rumor: ['rumor', 'Unconfirmed', false], ruled: ['neutral', 'Ruled', false], voided: ['neutral', 'Voided', false],
    sending: ['neutral', 'Sending', false], filled: ['up', 'Filled', false], resting: ['neutral', 'Resting', false],
    canceled: ['neutral', 'Canceled', false], liquidated: ['down', 'Liquidated', false], sec: ['down', 'SEC charge', false],
    beat: ['up', 'Beat', false], miss: ['down', 'Miss', false]
  };
  function StatusChip(p) {
    var s = STATUS[p.status] || STATUS.closed;
    return h('span', { className: cx('ax-chip', 'ax-chip-' + s[0], p.glass && 'ax-chip-glass') },
      s[2] ? h('span', { className: 'ax-dot', 'aria-hidden': 'true' }) : null, p.label || s[1]);
  }

  function Countdown(p) {
    return h('span', { className: cx('ax-countdown', 'ax-countdown-' + (p.tone || 'rumor')), role: 'timer', 'aria-label': (p.label || '') + ' ' + p.time },
      p.label ? h('span', null, p.label) : null, h('span', { className: 'ax-countdown-time' }, p.time));
  }

  function IconButton(p) {
    return h('button', { type: 'button', className: cx('ax-iconbtn', p.size === 'sm' && 'ax-iconbtn-sm'), 'aria-label': p.label, onClick: p.onClick },
      h(Icon, { name: p.icon, size: p.size === 'sm' ? 16 : 20, filled: p.filled }),
      p.badge ? h('span', { className: 'ax-badge', 'aria-hidden': 'true' }, p.badge) : null);
  }

  function Button(p) {
    var v = p.variant || 'secondary';
    return h('button', { type: 'button', disabled: p.disabled, onClick: p.onClick, className: cx('ax-btn', 'ax-btn-' + v, 'ax-btn-' + (p.size || 'lg'), p.block && 'ax-btn-block') },
      p.icon ? h(Icon, { name: p.icon, size: p.size === 'md' ? 16 : 18, weight: 2 }) : null, p.children);
  }

  function SlideToConfirm(p) {
    return h('div', { className: cx('ax-slide', p.tone === 'down' && 'ax-slide-down'), role: 'button', tabIndex: 0, 'aria-label': p.label + ', double-tap to confirm' },
      h('span', { className: 'ax-slide-knob', 'aria-hidden': 'true' }, h(Icon, { name: 'arrow', size: 20, weight: 2 })),
      h('span', { className: 'ax-slide-label' }, p.label));
  }

  function SegmentedControl(p) {
    var opts = p.options || [];
    return h('div', { className: 'ax-seg', role: 'tablist', 'aria-label': p.label },
      opts.map(function (o) {
        var sel = o === p.value;
        return h('button', { key: o, type: 'button', role: 'tab', 'aria-selected': sel, className: cx('ax-seg-item', sel && 'is-selected') }, o);
      }));
  }

  function Tabs(p) {
    return h('div', { className: 'ax-tabs', role: 'tablist', 'aria-label': p.label, style: { gridTemplateColumns: 'repeat(' + p.items.length + ', minmax(0, 1fr))' } },
      p.items.map(function (o) {
        var sel = o === p.value;
        return h('button', { key: o, type: 'button', role: 'tab', 'aria-selected': sel, className: cx('ax-tab', sel && 'is-selected') }, o);
      }));
  }

  function SearchField(p) {
    return h('label', { className: 'ax-search' },
      h(Icon, { name: 'search', size: 18 }),
      h('span', { className: 'ax-sr' }, 'Search'),
      h('input', { type: 'search', placeholder: p.placeholder || 'Search friends or tickers…', defaultValue: p.value }));
  }

  function SectionHeader(p) {
    return h('div', { className: 'ax-sechead' },
      h('div', { className: 'ax-sechead-title' }, h('h2', null, p.title), p.status ? h(StatusChip, { status: p.status, label: p.statusLabel }) : null),
      p.action ? h('button', { type: 'button', className: 'ax-link' }, p.action, h(Icon, { name: 'chevron', size: 14 })) : null);
  }

  function StatCard(p) {
    return h('div', { className: cx('ax-stat', p.wide && 'ax-stat-wide') },
      h('div', { className: 'ax-stat-top' }, h('span', { className: 'ax-stat-label' }, p.label),
        p.trailing ? h('span', { className: cx('ax-stat-trailing', p.trailingTone && 'ax-' + p.trailingTone) }, p.trailing) : null),
      h('span', { className: cx('ax-stat-value', p.tone && 'ax-' + p.tone) }, p.value),
      p.children);
  }

  function RangeBar(p) {
    var pct = Math.max(0, Math.min(100, (p.current - p.low) / (p.high - p.low) * 100));
    return h(StatCard, { label: p.label || 'Season range', trailing: p.note, trailingTone: p.noteTone || 'up', wide: true,
      value: h(window.React.Fragment, null, h(Money, { value: p.low }), h('span', { className: 'ax-range-sep' }, ' / '), h(Money, { value: p.high })) },
      h('span', { className: 'ax-range', role: 'img', 'aria-label': 'Current ' + fmt(p.current) + ', ' + Math.round(pct) + '% of the way from low to high' },
        h('span', { className: 'ax-range-fill', style: { width: pct + '%' } })));
  }

  function sparkPath(points, w, hgt) {
    var min = Math.min.apply(null, points), max = Math.max.apply(null, points), span = (max - min) || 1;
    return points.map(function (v, i) {
      var x = (i / (points.length - 1)) * w, y = hgt - 2 - ((v - min) / span) * (hgt - 4);
      return (i ? 'L' : 'M') + x.toFixed(1) + ' ' + y.toFixed(1);
    }).join(' ');
  }
  function Sparkline(p) {
    var w = p.width || 84, hgt = p.height || 30;
    var t = p.trend || trendOf(p.points[p.points.length - 1] - p.points[0]);
    return h('svg', { className: cx('ax-spark', 'ax-' + t), width: w, height: hgt, viewBox: '0 0 ' + w + ' ' + hgt, 'aria-hidden': 'true' },
      p.baseline !== false ? h('line', { x1: 0, x2: w, y1: hgt / 2, y2: hgt / 2, className: 'ax-spark-base' }) : null,
      h('path', { d: sparkPath(p.points, w, hgt), fill: 'none', stroke: 'currentColor', strokeWidth: 1.3, strokeLinejoin: 'round' }));
  }

  function StockRow(p) {
    var t = trendOf(p.pct);
    return h('div', { className: 'ax-row', role: 'listitem' },
      h(Avatar, { initial: p.initial || (p.ticker || '').replace('$', '').charAt(0), trend: t }),
      h('div', { className: 'ax-row-main' },
        h('span', { className: 'ax-row-title' }, p.ticker),
        h('span', { className: 'ax-row-sub' }, p.name, p.tag ? h(Tag, { tone: p.tagTone }, p.tag) : null)),
      p.points ? h(Sparkline, { points: p.points, trend: t }) : h('span'),
      h('div', { className: 'ax-row-end' }, h(Money, { value: p.price }), h(PriceChange, { abs: p.abs, pct: p.pct, size: 'sm' })));
  }

  function ActionButton(p) {
    return h('button', { type: 'button', className: 'ax-action', onClick: p.onClick },
      h('span', { className: 'ax-action-disc' }, h(Icon, { name: p.icon, size: 22 })), p.label);
  }

  function HeroCard(p) {
    return h('section', { className: cx('ax-hero', p.tone === 'down' && 'ax-hero-down'), 'aria-label': p.label },
      h('span', { className: 'ax-hero-label' }, p.label),
      h('div', { className: 'ax-hero-value' }, h(Money, { value: p.value, size: 'display', approx: p.approx }),
        p.hideable ? h(IconButton, { icon: 'eyeOff', label: 'Hide balance', size: 'sm' }) : null),
      p.abs != null || p.pct != null ? h(PriceChange, { abs: p.abs, pct: p.pct, period: p.period }) : null,
      p.note ? h('span', { className: 'ax-hero-note' }, p.note) : null,
      p.actions ? h('div', { className: 'ax-hero-actions' }, p.actions.map(function (a) { return h(ActionButton, { key: a.label, icon: a.icon, label: a.label }); })) : null,
      p.children);
  }

  function NavRow(p) {
    return h('button', { type: 'button', className: 'ax-navrow', onClick: p.onClick },
      p.icon ? h('span', { className: 'ax-tile' }, h(Icon, { name: p.icon, size: 18 })) : null,
      h('span', { className: 'ax-navrow-text' }, h('span', { className: 'ax-navrow-title' }, p.title), p.subtitle ? h('span', { className: 'ax-navrow-sub' }, p.subtitle) : null),
      p.trailing ? h('span', { className: cx('ax-navrow-trailing', p.trailingTone && 'ax-' + p.trailingTone) }, p.trailing) : null,
      h(Icon, { name: 'arrow', size: 18 }));
  }

  function NavCard(p) {
    return h('div', { className: 'ax-navcard' }, p.children);
  }

  function QuoteCard(p) {
    return h('blockquote', { className: 'ax-quote' }, p.quote, p.source ? h('span', { className: 'ax-quote-source' }, p.source) : null);
  }

  function ImpactDisc(p) {
    var t = trendOf(p.delta);
    return h('span', { className: cx('ax-impact', 'ax-impact-' + t), role: 'img', 'aria-label': (p.label || '') + ' impact ' + signed(p.delta).replace('.00', '') },
      h('span', { className: 'ax-impact-num' }, signed(p.delta).replace('.00', '')), p.label ? h('span', { className: 'ax-impact-label' }, p.label) : null);
  }

  function ChartTooltip(p) {
    return h('span', { className: 'ax-tooltip' }, h(Money, { value: p.price }), p.badge ? h('span', { className: cx('ax-tooltip-badge', 'ax-tooltip-' + (p.tone || 'up')) }, p.badge) : null);
  }

  var BANNER_ICON = { neutral: 'clock', warn: 'alert', down: 'alert', rumor: 'bolt', offline: 'wifiOff' };
  function Banner(p) {
    var tone = p.tone || 'neutral';
    return h('div', { className: cx('ax-banner', 'ax-banner-' + tone), role: tone === 'down' || tone === 'warn' ? 'alert' : 'status' },
      h(Icon, { name: p.icon || BANNER_ICON[tone] || 'clock', size: 18 }),
      h('div', { className: 'ax-banner-text' }, h('span', { className: 'ax-banner-title' }, p.title), p.body ? h('span', { className: 'ax-banner-body' }, p.body) : null),
      p.action ? h('button', { type: 'button', className: 'ax-banner-action' }, p.action) : null);
  }

  function EmptyState(p) {
    return h('div', { className: 'ax-empty' },
      h('span', { className: 'ax-tile ax-tile-lg' }, h(Icon, { name: p.icon || 'tape', size: 24 })),
      h('span', { className: 'ax-empty-title' }, p.title),
      p.body ? h('span', { className: 'ax-empty-body' }, p.body) : null,
      p.action ? h(Button, { variant: 'primary', size: 'md' }, p.action) : null);
  }

  function Toast(p) {
    return h('div', { className: 'ax-toast', role: 'status' },
      p.icon ? h(Icon, { name: p.icon, size: 18 }) : null,
      h('span', { className: 'ax-toast-text' }, p.message),
      p.action ? h('button', { type: 'button', className: 'ax-toast-action' }, p.action) : null);
  }

  function Sheet(p) {
    return h('div', { className: 'ax-sheet', role: 'dialog', 'aria-label': p.title },
      h('span', { className: 'ax-grabber', 'aria-hidden': 'true' }),
      p.title ? h('div', { className: 'ax-sheet-head' }, h('h2', null, p.title), h(IconButton, { icon: 'close', label: 'Close', size: 'sm' })) : null,
      p.children);
  }

  var TABS = [['home', 'Home'], ['market', 'Market'], ['tape', 'Tape'], ['portfolio', 'Portfolio'], ['you', 'You']];
  function TabBar(p) {
    var active = p.active || 'home';
    return h('nav', { className: 'ax-tabbar', 'aria-label': 'Main' },
      TABS.map(function (t) {
        var on = t[0] === active;
        return h('button', { key: t[0], type: 'button', className: cx('ax-tabbar-item', on && 'is-active'), 'aria-label': t[1], 'aria-current': on ? 'page' : undefined },
          h(Icon, { name: t[0], size: 22, weight: on ? 2.2 : 1.9 }),
          t[0] === 'tape' && p.tapeBadge ? h('span', { className: 'ax-badge', 'aria-hidden': 'true' }, p.tapeBadge) : null);
      }));
  }

  /* The ticker tape: the app's signature strip. */
  function Tape(p) {
    return h('div', { className: 'ax-tape', role: 'marquee', 'aria-label': 'Ticker tape' },
      (p.items || []).map(function (it) {
        var t = trendOf(it.pct);
        return h('span', { key: it.ticker, className: 'ax-tape-item' }, it.ticker + ' ' + fmt(it.price) + ' ',
          h('span', { className: 'ax-' + t }, (t === 'up' ? '\u25B2 ' : t === 'down' ? '\u25BC ' : '') + fmt(it.pct) + '%'));
      }));
  }

  /* A receipt: label and value rows on hairlines, with a total. */
  function Stepper(p) {
    return h('div', { className: 'ax-stepper', role: 'group', 'aria-label': p.label || 'Quantity' },
      h(IconButton, { icon: 'minus', label: 'One fewer' }),
      h('div', { className: 'ax-stepper-mid' }, h('span', { className: 'ax-stepper-value', 'aria-live': 'polite' }, p.value), p.note ? h('span', { className: 'ax-stepper-note' }, p.note) : null),
      h(IconButton, { icon: 'plus', label: 'One more' }));
  }

  function Receipt(p) {
    return h('div', { className: 'ax-receipt' },
      (p.rows || []).map(function (r) { return h('div', { key: r.label, className: 'ax-receipt-row' }, h('span', null, r.label), h('span', { className: r.tone ? 'ax-' + r.tone : null }, r.value)); }),
      p.total ? h('div', { className: 'ax-receipt-row ax-receipt-total' }, h('span', null, p.total.label), h('span', { className: p.total.tone ? 'ax-' + p.total.tone : null }, p.total.value)) : null);
  }

  window.Aura = Object.assign(window.Aura || {}, {
    Tape: Tape, Receipt: Receipt, Stepper: Stepper,
    Money: Money, PriceChange: PriceChange, Avatar: Avatar, Tag: Tag, StatusChip: StatusChip, Countdown: Countdown,
    Icon: Icon, IconButton: IconButton, Button: Button, SlideToConfirm: SlideToConfirm, SegmentedControl: SegmentedControl,
    Tabs: Tabs, SearchField: SearchField, SectionHeader: SectionHeader, StatCard: StatCard, RangeBar: RangeBar,
    Sparkline: Sparkline, StockRow: StockRow, HeroCard: HeroCard, ActionButton: ActionButton, NavCard: NavCard, NavRow: NavRow,
    QuoteCard: QuoteCard, ImpactDisc: ImpactDisc, ChartTooltip: ChartTooltip, Banner: Banner, EmptyState: EmptyState,
    Toast: Toast, Sheet: Sheet, TabBar: TabBar
  });
})();
