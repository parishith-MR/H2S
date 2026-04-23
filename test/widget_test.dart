import 'package:flutter_test/flutter_test.dart';
import 'package:h2s/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SportShieldApp());
    await tester.pump(const Duration(seconds: 1));
    // Just check the app builds without crashing
    expect(find.byType(SportShieldApp), findsOneWidget);
  });
}
