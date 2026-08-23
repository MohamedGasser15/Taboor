// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Taboor';

  @override
  String get appTagline => 'Save time, don\'t live in queues.';

  @override
  String get back => 'Back';

  @override
  String get or => 'or';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••••';

  @override
  String get loginWelcomeTitle => 'Welcome back';

  @override
  String get loginWelcomeSubtitle =>
      'Sign in and continue your request in the queue';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get noAccountYet => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create account';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get registerSubtitle =>
      'Start with your email\nand we\'ll send you a verification code';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpDescription(String email) {
    return 'Enter the 6-digit code\nsent to $email';
  }

  @override
  String get yourEmailFallback => 'your email';

  @override
  String get resendPrompt => 'Didn\'t get the code?';

  @override
  String get resend => 'Resend';

  @override
  String get verify => 'Verify';

  @override
  String get completeDetails => 'Complete your details';

  @override
  String get detailsSubtitle => 'Name, phone and password to finish';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'e.g. Mohamed Ahmed';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '01xxxxxxxxx';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordMismatch => 'Passwords don\'t match';

  @override
  String get createAccountSubmit => 'Create account';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotSubtitle =>
      'Enter your email\nand we\'ll send you a verification code';

  @override
  String get rememberPassword => 'Remembered your password?';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get newPasswordSubtitle => 'Enter a new password and confirm it';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get savePassword => 'Save password';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get genericRequestError => 'Something went wrong. Please try again.';

  @override
  String get invalidEmail => 'Please enter a valid email.';

  @override
  String get emailRequired => 'Please enter your email.';

  @override
  String get codeRequired => 'Please enter the verification code.';

  @override
  String get fullNameRequired => 'Please enter your full name.';

  @override
  String get phoneRequired => 'Please enter your phone number.';

  @override
  String get passwordRequired => 'Please enter a password.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get emailAlreadyExists => 'This email is already registered.';

  @override
  String get phoneAlreadyExists => 'This phone number is already registered.';

  @override
  String get emailNotConfirmed =>
      'Please verify your email with the OTP code first.';

  @override
  String get invalidCode => 'The verification code is invalid or has expired.';

  @override
  String get verificationSent => 'Verification code sent to your email.';

  @override
  String get emailConfirmed => 'Email confirmed successfully.';

  @override
  String get registrationSuccess => 'Registration successful.';

  @override
  String get loginSuccess => 'Login successful.';

  @override
  String get passwordResetNotAvailable => 'Password reset is coming soon.';

  @override
  String get countrySelectTitle => 'Select country';

  @override
  String get countrySearchHint => 'Search country or code...';

  @override
  String get resetCodeSent =>
      'If this email is registered, we\'ve sent a reset code.';

  @override
  String get resetCodeVerified =>
      'Code verified. You can now reset your password.';

  @override
  String get resetSuccess => 'Password reset successfully. You can now log in.';

  @override
  String get resetCodeInvalid => 'The reset code is invalid or has expired.';

  @override
  String get newPasswordShort => 'Password must be at least 6 characters.';

  @override
  String get passwordWeak =>
      'Password must be at least 8 characters with a number and a capital letter.';

  @override
  String get passwordWeakLabel => 'Weak';

  @override
  String get passwordMediumLabel => 'Medium';

  @override
  String get passwordStrongLabel => 'Strong';

  @override
  String get passwordVeryStrongLabel => 'Very strong';

  @override
  String get passwordMatchOk => 'Passwords match';

  @override
  String get latinOnly => 'Use English letters and numbers only.';

  @override
  String get tryingText => 'Trying...';

  @override
  String get onboardingOneTitle => 'Wait, from the comfort of your home';

  @override
  String get onboardingOneSubtitle =>
      'Reserve your spot from anywhere\nand get your instant number for free';

  @override
  String get onboardingTwoTitle => 'Your turn... minute by minute';

  @override
  String get onboardingTwoSubtitle =>
      'Track your queue rank live\nwith a clear counter and progress bar';

  @override
  String get onboardingThreeTitle => 'We\'ll alert you before your turn';

  @override
  String get onboardingThreeSubtitle =>
      'Smart alerts tell you when to head out\n\"Time to go — only two ahead!\"';

  @override
  String get ticketNumberLabel => 'Your number';

  @override
  String get ticketSitRelax => 'Take a seat & chill';

  @override
  String get liveAhead => 'Ahead of you';

  @override
  String get liveTurnNear => 'Your turn is near';

  @override
  String get alertNow => 'now';

  @override
  String get alertLeaveTitle => 'Time to head out!';

  @override
  String get alertOnlyTwo => 'Only 2 in front of you';

  @override
  String get next => 'Next';

  @override
  String get startNow => 'Get started';

  @override
  String get homeTitle => 'Get your turn from anywhere';

  @override
  String get homeSoon => 'Home page coming soon';

  @override
  String get homeCta => 'Take a tour of Taboor';

  @override
  String get welcomeBack => 'Welcome back,';
}
