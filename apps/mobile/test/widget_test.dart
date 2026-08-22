import 'package:flutter_test/flutter_test.dart';

import 'package:taboor/features/splash/presentation/screens/splash_screen.dart';
import 'package:taboor/main.dart';

void main() {
  testWidgets('Splash screen renders the Taboor logo', (tester) async {
    await tester.pumpWidget(const TaboorApp());
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}