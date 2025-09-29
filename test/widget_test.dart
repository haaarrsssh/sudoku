import 'package:flutter_test/flutter_test.dart' show WidgetTester, expect, find, findsOneWidget, testWidgets;
import 'package:sudoku_game/main.dart';

void main() {
  testWidgets('Sudoku app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SudokuApp());

    // Verify that the welcome screen loads with the correct elements
    expect(find.text('SUDOKU'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
  });
}