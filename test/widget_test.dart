import 'package:flutter_test/flutter_test.dart';

import 'package:weara_app/main.dart';

void main() {
  testWidgets('Splash screen shows WEARA title', (WidgetTester tester) async {
    await tester.pumpWidget(const WearaApp());

    expect(find.text('WEARA'), findsOneWidget);
    expect(find.text('Your clothes. Your style.'), findsOneWidget);
    expect(find.text('Ver. 0.1.0'), findsOneWidget);
  });
}
