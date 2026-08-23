// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'طابور';

  @override
  String get appTagline => 'وِفر وقتك، ومتعيشش في الطابور';

  @override
  String get back => 'رجوع';

  @override
  String get or => 'أو';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => '••••••••••';

  @override
  String get loginWelcomeTitle => 'أهلًا بيك من جديد';

  @override
  String get loginWelcomeSubtitle => 'سجّل دخولك واستكمل طلبك في الطابور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get noAccountYet => 'مش عندك حساب؟';

  @override
  String get createAccount => 'أنشئ حسابًا';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get registerSubtitle =>
      'ابدأ بالبريد الإلكتروني\nوهنبعث لك كود التحقق';

  @override
  String get alreadyHaveAccount => 'عندك حساب بالفعل؟';

  @override
  String get sendCode => 'إرسال الكود';

  @override
  String get otpTitle => 'كود التحقق';

  @override
  String otpDescription(String email) {
    return 'أدخل الكود المكون من 6 أرقام\nأُرسل إلى $email';
  }

  @override
  String get yourEmailFallback => 'بريدك الإلكتروني';

  @override
  String get resendPrompt => 'لم يصلك الكود؟';

  @override
  String get resend => 'إعادة الإرسال';

  @override
  String get verify => 'تحقق';

  @override
  String get completeDetails => 'كمل بياناتك';

  @override
  String get detailsSubtitle => 'الاسم وهاتفك وكلمة المرور عشان تكمّل';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameHint => 'مثال: محمد أحمد';

  @override
  String get phoneLabel => 'رقم الموبايل';

  @override
  String get phoneHint => '01xxxxxxxxx';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get createAccountSubmit => 'إنشاء الحساب';

  @override
  String get forgotTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotSubtitle => 'اكتب بريدك الإلكتروني\nوهنبعث لك كود التحقق';

  @override
  String get rememberPassword => 'فتكرت كلمة المرور؟';

  @override
  String get newPasswordTitle => 'كلمة مرور جديدة';

  @override
  String get newPasswordSubtitle => 'اكتب كلمة مرورة جديدة وتأكد منها';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get savePassword => 'حفظ كلمة المرور';

  @override
  String get networkError => 'مشكلة في الاتصال. تأكد من النت.';

  @override
  String get genericRequestError => 'حصلت مشكلة. جرب تاني.';

  @override
  String get invalidEmail => 'اكتب إيميل صحيح.';

  @override
  String get emailRequired => 'اكتب إيميلك.';

  @override
  String get codeRequired => 'اكتب كود التحقق.';

  @override
  String get fullNameRequired => 'اكتب اسمك بالكامل.';

  @override
  String get phoneRequired => 'اكتب رقم موبايلك.';

  @override
  String get passwordRequired => 'اكتب كلمة المرور.';

  @override
  String get invalidCredentials => 'الإيميل أو كلمة المرور غلط.';

  @override
  String get emailAlreadyExists => 'الإيميل ده مسجل بالفعل.';

  @override
  String get phoneAlreadyExists => 'رقم الموبايل ده مسجل بالفعل.';

  @override
  String get emailNotConfirmed => 'أكّد إيميلك بكود التحقق الأول.';

  @override
  String get invalidCode => 'كود التحقق غلط أو انتهى.';

  @override
  String get verificationSent => 'ابتعثنا كود التحقق لإيميلك.';

  @override
  String get emailConfirmed => 'تم تأكيد الإيميل.';

  @override
  String get registrationSuccess => 'تم إنشاء الحساب بنجاح.';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح.';

  @override
  String get passwordResetNotAvailable => 'استعادة كلمة المرور قريباً.';

  @override
  String get countrySelectTitle => 'اختار الدولة';

  @override
  String get countrySearchHint => 'دوّر على دولة أو كود...';

  @override
  String get resetCodeSent => 'لو الإيميل مسجل، بعتنا كود استعادة.';

  @override
  String get resetCodeVerified => 'تم التحقق من الكود. تقدر تغير كلمة المرور.';

  @override
  String get resetSuccess => 'تم تغيير كلمة المرور. تقدر تسجل دخولك.';

  @override
  String get resetCodeInvalid => 'كود الاستعادة غلط أو انتهى.';

  @override
  String get newPasswordShort => 'كلمة المرور لازم تكون 6 أحرف على الأقل.';

  @override
  String get passwordWeak => 'كلمة المرور لازم تكون 8 أحرف + رقم + حرف كبير.';

  @override
  String get passwordWeakLabel => 'ضعيفة';

  @override
  String get passwordMediumLabel => 'متوسطة';

  @override
  String get passwordStrongLabel => 'قوية';

  @override
  String get passwordVeryStrongLabel => 'قوية جداً';

  @override
  String get passwordMatchOk => 'كلمتا المرور متطابقتين';

  @override
  String get latinOnly => 'اكتب بإنجليزي (حروف وأرقام انجليزية بس).';

  @override
  String get tryingText => 'اللحظات...';

  @override
  String get onboardingOneTitle => 'استنى وأنت في بيتك';

  @override
  String get onboardingOneSubtitle =>
      'سجّل مكانك من أي مكان\nواحصل على رقمك الفوري مجاناً';

  @override
  String get onboardingTwoTitle => 'دورك.. لحظة بلحظة';

  @override
  String get onboardingTwoSubtitle =>
      'تابع ترتيبك في الطابور مباشر\nمع عداد واضح ومؤشر تقدم';

  @override
  String get onboardingThreeTitle => 'هننبهك قبل ما يجي دورك';

  @override
  String get onboardingThreeSubtitle =>
      'اشعارات ذكية تقولك امتى تخرج\n\"وقت الخروج - قدامك اتنين بس!\"';

  @override
  String get ticketNumberLabel => 'رقمك';

  @override
  String get ticketSitRelax => 'مجلسك وريح';

  @override
  String get liveAhead => 'أمامك';

  @override
  String get liveTurnNear => 'دورك قرب';

  @override
  String get alertNow => 'الآن';

  @override
  String get alertLeaveTitle => 'وقت الخروج!';

  @override
  String get alertOnlyTwo => 'قدامك 2 فقط';

  @override
  String get next => 'التالي';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get homeTitle => 'اطلب دورك من أي مكان';

  @override
  String get homeSoon => 'الصفحة الرئيسية قريباً';

  @override
  String get homeCta => 'عرفني على طابور';

  @override
  String get welcomeBack => 'أهلًا من جديد،';
}
