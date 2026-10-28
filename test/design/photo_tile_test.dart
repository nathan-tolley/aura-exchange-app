import 'package:aura_exchange/design/widgets/aura_photo_tile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// `AuraPhotoTile`: a receipt in the filing sheet, or the slot that adds one.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    AuraTestApp(
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
  const photo = ColoredBox(color: Color(0xFF445566));

  testWidgets('the add slot is a named button', (tester) async {
    var taps = 0;
    await pump(
      tester,
      AuraPhotoTile.add(label: 'Add a receipt', onTap: () => taps++),
    );
    expect(tester.getSize(find.byType(AuraPhotoTile)), const Size(64, 64));
    await tester.tap(find.bySemanticsLabel('Add a receipt'));
    expect(taps, 1);
  });

  testWidgets('remove has a 44 pt target in the corner, apart from the tile', (
    tester,
  ) async {
    var removed = 0;
    var tapped = 0;
    await pump(
      tester,
      AuraPhotoTile(
        image: photo,
        label: "Receipt 1, didn't upload",
        status: AuraPhotoStatus.failed,
        onTap: () => tapped++,
        onRemove: () => removed++,
        removeLabel: 'Remove receipt 1',
      ),
    );
    final target = find.bySemanticsLabel('Remove receipt 1');
    expect(tester.getSize(target), const Size(44, 44));
    await tester.tap(target);
    expect((removed, tapped), (1, 0));

    // The rest of the tile tries again.
    await tester.tapAt(
      tester.getTopLeft(find.byType(AuraPhotoTile)) + const Offset(10, 54),
    );
    expect((removed, tapped), (1, 1));
  });

  testWidgets('uploading shows how much has been sent', (tester) async {
    await pump(
      tester,
      const AuraPhotoTile(
        image: photo,
        label: 'Receipt 2, uploading',
        status: AuraPhotoStatus.uploading,
        progress: 0.6,
      ),
    );
    final bar = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(bar.widthFactor, 0.6);
    expect(find.bySemanticsLabel('Receipt 2, uploading'), findsOneWidget);
  });
}
