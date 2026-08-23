import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taboor/core/services/locale_service.dart';
import 'package:taboor/core/utils/shared_prefs.dart';
import 'package:taboor/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:taboor/features/auth/presentation/screens/login_screen.dart';
import 'package:taboor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:taboor/features/splash/presentation/screens/splash_screen.dart';
import 'package:taboor/main.dart';
import 'package:taboor/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefs.init();
    await LocaleService.setLocale(const Locale('ar'));
  });

  testWidgets('Splash renders and navigates to onboarding for first-time',
      (tester) async {
    await tester.pumpWidget(const TaboorApp());

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('Locale can be toggled to English', (tester) async {
    await LocaleService.setLocale(const Locale('en'));
    expect(LocaleService.isArabic, isFalse);
  });

  testWidgets('Language toggle updates login screen text', (tester) async {
    await tester.pumpWidget(const TaboorApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.tap(find.text('التالي'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('التالي'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(LoginScreen), findsOneWidget);

    final l10nAr = AppLocalizations.of(tester.element(find.byType(LoginScreen)));
    expect(l10nAr.loginWelcomeTitle, 'أهلًا بيك من جديد');

    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(LocaleService.isArabic, isFalse, reason: 'locale should flip to en');
    expect(find.text('Welcome back'), findsOneWidget,
        reason: 'login screen should render in English after toggle');
    expect(find.text('أهلًا بيك من جديد'), findsNothing);

    final l10nEn = AppLocalizations.of(tester.element(find.byType(LoginScreen)));
    expect(l10nEn.loginWelcomeTitle, 'Welcome back');
  });

  testWidgets('Login shows error on empty inputs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const LoginScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.text('تسجيل الدخول'));
    await tester.pump();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();

    expect(find.text('اكتب إيميلك.'), findsOneWidget);
    expect(find.text('اكتب كلمة المرور.'), findsOneWidget);
  });

  testWidgets('Login clears field errors when typing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const LoginScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.text('تسجيل الدخول'));
    await tester.pump();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    expect(find.text('اكتب إيميلك.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'a@b.com');
    await tester.pump();
    expect(find.text('اكتب إيميلك.'), findsNothing);
  });

  testWidgets('Forgot password shows error on empty email', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ForgotPasswordScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.text('إرسال الكود'));
    await tester.pump();
    await tester.tap(find.text('إرسال الكود'));
    await tester.pump();

    expect(find.text('اكتب إيميلك.'), findsOneWidget);
  });
}