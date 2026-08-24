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

  @override
  String get navHome => 'Home';

  @override
  String get navQueue => 'My Queue';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get homeSearchHint => 'Search clinics, salons, garages...';

  @override
  String get homeLiveTicket => 'Your live ticket';

  @override
  String get homeNoTicket => 'No active ticket';

  @override
  String get homeJoinQueue => 'Join a queue';

  @override
  String get homeNearby => 'Nearby services';

  @override
  String get homePopularNearYou => 'Popular near you';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get categoryClinics => 'Clinics';

  @override
  String get categorySalons => 'Salons';

  @override
  String get categoryGarages => 'Auto repair';

  @override
  String get categoryOffices => 'Offices';

  @override
  String peopleWaiting(int count) {
    return '$count waiting';
  }

  @override
  String distanceAway(String km) {
    return '$km km away';
  }

  @override
  String get joinNow => 'Join';

  @override
  String get queueEmptyTitle => 'No active queue yet';

  @override
  String get queueEmptySubtitle => 'Find a nearby service and grab your number';

  @override
  String get queueNowServing => 'Now serving';

  @override
  String queuePeopleAhead(int count) {
    return '$count ahead of you';
  }

  @override
  String get queueEstimate => 'Est. wait';

  @override
  String queueMinutes(int count) {
    return '$count min';
  }

  @override
  String get alertsEmptyTitle => 'You\'re all caught up';

  @override
  String get alertsEmptySubtitle =>
      'Smart alerts about your turn will show up here';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignOutConfirm => 'Sign out of your account?';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileSignOutOk => 'Sign out';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileBiometric => 'Unlock with biometrics';

  @override
  String get profileBiometricSubtitle =>
      'Use Face ID or fingerprint to sign in';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileChangePasswordSubtitle => 'Update your account password';

  @override
  String get profileAbout => 'About';

  @override
  String get profileVersion => 'Version';

  @override
  String get profileSettings => 'Settings';

  @override
  String get biometricUnavailable =>
      'Biometrics aren\'t available on this device.';

  @override
  String get biometricAuthRequired => 'Confirm to enable';

  @override
  String get biometricEnabled => 'Biometric unlock enabled.';

  @override
  String get biometricDisabled => 'Biometric unlock disabled.';

  @override
  String get appLanguage => 'App language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get editProfile => 'Edit account';

  @override
  String get editProfileSave => 'Save changes';

  @override
  String get editProfileSaved => 'Account updated.';

  @override
  String get oldPasswordLabel => 'Current password';

  @override
  String get oldPasswordHint => 'Enter your current password';

  @override
  String get newPasswordLabel2 => 'New password';

  @override
  String get changePasswordDone => 'Password changed successfully.';

  @override
  String get forgotPasswordHere => 'Forgot password?';

  @override
  String get serviceChooseBranch => 'Choose a branch';

  @override
  String get serviceBranches => 'Branches';

  @override
  String get serviceOpenNow => 'Open now';

  @override
  String get serviceClosed => 'Closed';

  @override
  String serviceWaitingNow(Object count) {
    return '$count waiting now';
  }

  @override
  String get serviceEstWait => 'Est. wait';

  @override
  String get serviceJoinQueue => 'Join this queue';

  @override
  String get serviceAbout => 'About this service';

  @override
  String get serviceWorkingHours => 'Working hours';

  @override
  String get serviceTapHint => 'Tap to view details';

  @override
  String get branchMain => 'Main branch';

  @override
  String get branchDowntown => 'Downtown branch';

  @override
  String get branchNorth => 'North branch';

  @override
  String get branchAirport => 'Airport branch';

  @override
  String get branchWest => 'West branch';

  @override
  String get allServicesTitle => 'Services near you';

  @override
  String get allServicesSubtitle => 'Live queues around you';

  @override
  String get filterAll => 'All';

  @override
  String get popService => 'Popular';

  @override
  String get mapLocate => 'Locate me';

  @override
  String get mapLocating => 'Locating…';

  @override
  String get mapLocationUnavailable =>
      'Location is off or permission is denied.';

  @override
  String get mapYouAreHere => 'You are here';

  @override
  String mapDistanceAway(Object km) {
    return '$km away';
  }

  @override
  String mapDriveTime(Object min) {
    return '~$min min drive';
  }

  @override
  String get mapOpenInGoogleMaps => 'Open in Google Maps';

  @override
  String get mapOpenInAppleMaps => 'Open in Apple Maps';

  @override
  String get mapDirections => 'Directions';

  @override
  String get geoFrom => 'Current location';

  @override
  String get geoTo => 'Branch';
}
