import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Taboor'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Save time, don\'t live in queues.'**
  String get appTagline;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••••'**
  String get passwordHint;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in and continue your request in the queue'**
  String get loginWelcomeSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountYet;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with your email\nand we\'ll send you a verification code'**
  String get registerSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpTitle;

  /// No description provided for @otpDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code\nsent to {email}'**
  String otpDescription(String email);

  /// No description provided for @yourEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmailFallback;

  /// No description provided for @resendPrompt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code?'**
  String get resendPrompt;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @completeDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete your details'**
  String get completeDetails;

  /// No description provided for @detailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, phone and password to finish'**
  String get detailsSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mohamed Ahmed'**
  String get fullNameHint;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'01xxxxxxxxx'**
  String get phoneHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordMismatch;

  /// No description provided for @createAccountSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountSubmit;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email\nand we\'ll send you a verification code'**
  String get forgotSubtitle;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remembered your password?'**
  String get rememberPassword;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password and confirm it'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @genericRequestError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericRequestError;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get emailRequired;

  /// No description provided for @codeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code.'**
  String get codeRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get fullNameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get phoneRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get passwordRequired;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailAlreadyExists;

  /// No description provided for @phoneAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered.'**
  String get phoneAlreadyExists;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email with the OTP code first.'**
  String get emailNotConfirmed;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'The verification code is invalid or has expired.'**
  String get invalidCode;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email.'**
  String get verificationSent;

  /// No description provided for @emailConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed successfully.'**
  String get emailConfirmed;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful.'**
  String get registrationSuccess;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful.'**
  String get loginSuccess;

  /// No description provided for @passwordResetNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Password reset is coming soon.'**
  String get passwordResetNotAvailable;

  /// No description provided for @countrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get countrySelectTitle;

  /// No description provided for @countrySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search country or code...'**
  String get countrySearchHint;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'If this email is registered, we\'ve sent a reset code.'**
  String get resetCodeSent;

  /// No description provided for @resetCodeVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified. You can now reset your password.'**
  String get resetCodeVerified;

  /// No description provided for @resetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. You can now log in.'**
  String get resetSuccess;

  /// No description provided for @resetCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'The reset code is invalid or has expired.'**
  String get resetCodeInvalid;

  /// No description provided for @newPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get newPasswordShort;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters with a number and a capital letter.'**
  String get passwordWeak;

  /// No description provided for @passwordWeakLabel.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeakLabel;

  /// No description provided for @passwordMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordMediumLabel;

  /// No description provided for @passwordStrongLabel.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrongLabel;

  /// No description provided for @passwordVeryStrongLabel.
  ///
  /// In en, this message translates to:
  /// **'Very strong'**
  String get passwordVeryStrongLabel;

  /// No description provided for @passwordMatchOk.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordMatchOk;

  /// No description provided for @latinOnly.
  ///
  /// In en, this message translates to:
  /// **'Use English letters and numbers only.'**
  String get latinOnly;

  /// No description provided for @tryingText.
  ///
  /// In en, this message translates to:
  /// **'Trying...'**
  String get tryingText;

  /// No description provided for @loggingInText.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loggingInText;

  /// No description provided for @onboardingOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Wait, from the comfort of your home'**
  String get onboardingOneTitle;

  /// No description provided for @onboardingOneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reserve your spot from anywhere\nand get your instant number for free'**
  String get onboardingOneSubtitle;

  /// No description provided for @onboardingTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your turn... minute by minute'**
  String get onboardingTwoTitle;

  /// No description provided for @onboardingTwoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your queue rank live\nwith a clear counter and progress bar'**
  String get onboardingTwoSubtitle;

  /// No description provided for @onboardingThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll alert you before your turn'**
  String get onboardingThreeTitle;

  /// No description provided for @onboardingThreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart alerts tell you when to head out\n\"Time to go — only two ahead!\"'**
  String get onboardingThreeSubtitle;

  /// No description provided for @ticketNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Your number'**
  String get ticketNumberLabel;

  /// No description provided for @ticketSitRelax.
  ///
  /// In en, this message translates to:
  /// **'Take a seat & chill'**
  String get ticketSitRelax;

  /// No description provided for @liveAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead of you'**
  String get liveAhead;

  /// No description provided for @liveTurnNear.
  ///
  /// In en, this message translates to:
  /// **'Your turn is near'**
  String get liveTurnNear;

  /// No description provided for @alertNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get alertNow;

  /// No description provided for @alertLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to head out!'**
  String get alertLeaveTitle;

  /// No description provided for @alertOnlyTwo.
  ///
  /// In en, this message translates to:
  /// **'Only 2 in front of you'**
  String get alertOnlyTwo;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get startNow;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Get your turn from anywhere'**
  String get homeTitle;

  /// No description provided for @homeSoon.
  ///
  /// In en, this message translates to:
  /// **'Home page coming soon'**
  String get homeSoon;

  /// No description provided for @homeCta.
  ///
  /// In en, this message translates to:
  /// **'Take a tour of Taboor'**
  String get homeCta;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navQueue.
  ///
  /// In en, this message translates to:
  /// **'My Queue'**
  String get navQueue;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search clinics, salons, garages...'**
  String get homeSearchHint;

  /// No description provided for @homeLiveTicket.
  ///
  /// In en, this message translates to:
  /// **'Your live ticket'**
  String get homeLiveTicket;

  /// No description provided for @homeNoTicket.
  ///
  /// In en, this message translates to:
  /// **'No active ticket'**
  String get homeNoTicket;

  /// No description provided for @homeJoinQueue.
  ///
  /// In en, this message translates to:
  /// **'Join a queue'**
  String get homeJoinQueue;

  /// No description provided for @homeNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby services'**
  String get homeNearby;

  /// No description provided for @homePopularNearYou.
  ///
  /// In en, this message translates to:
  /// **'Popular near you'**
  String get homePopularNearYou;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @categoryClinics.
  ///
  /// In en, this message translates to:
  /// **'Clinics'**
  String get categoryClinics;

  /// No description provided for @categorySalons.
  ///
  /// In en, this message translates to:
  /// **'Salons'**
  String get categorySalons;

  /// No description provided for @categoryGarages.
  ///
  /// In en, this message translates to:
  /// **'Auto repair'**
  String get categoryGarages;

  /// No description provided for @categoryOffices.
  ///
  /// In en, this message translates to:
  /// **'Offices'**
  String get categoryOffices;

  /// No description provided for @peopleWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String peopleWaiting(int count);

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String distanceAway(String km);

  /// No description provided for @joinNow.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinNow;

  /// No description provided for @queueEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active queue yet'**
  String get queueEmptyTitle;

  /// No description provided for @queueEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a nearby service and grab your number'**
  String get queueEmptySubtitle;

  /// No description provided for @queueNowServing.
  ///
  /// In en, this message translates to:
  /// **'Now serving'**
  String get queueNowServing;

  /// No description provided for @queuePeopleAhead.
  ///
  /// In en, this message translates to:
  /// **'{count} ahead of you'**
  String queuePeopleAhead(int count);

  /// No description provided for @queueEstimate.
  ///
  /// In en, this message translates to:
  /// **'Est. wait'**
  String get queueEstimate;

  /// No description provided for @queueMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String queueMinutes(int count);

  /// No description provided for @alertsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get alertsEmptyTitle;

  /// No description provided for @alertsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart alerts about your turn will show up here'**
  String get alertsEmptySubtitle;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account?'**
  String get profileSignOutConfirm;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileSignOutOk.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutOk;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurity;

  /// No description provided for @profileBiometric.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get profileBiometric;

  /// No description provided for @profileBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or fingerprint to sign in'**
  String get profileBiometricSubtitle;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get profileChangePasswordSubtitle;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersion;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics aren\'t available on this device.'**
  String get biometricUnavailable;

  /// No description provided for @biometricAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable'**
  String get biometricAuthRequired;

  /// No description provided for @biometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock enabled.'**
  String get biometricEnabled;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock disabled.'**
  String get biometricDisabled;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editProfile;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editProfileSave;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Account updated.'**
  String get editProfileSaved;

  /// No description provided for @oldPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get oldPasswordLabel;

  /// No description provided for @oldPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get oldPasswordHint;

  /// No description provided for @newPasswordLabel2.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel2;

  /// No description provided for @changePasswordDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get changePasswordDone;

  /// No description provided for @forgotPasswordHere.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordHere;

  /// No description provided for @serviceChooseBranch.
  ///
  /// In en, this message translates to:
  /// **'Choose a branch'**
  String get serviceChooseBranch;

  /// No description provided for @serviceBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get serviceBranches;

  /// No description provided for @serviceOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get serviceOpenNow;

  /// No description provided for @serviceClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get serviceClosed;

  /// No description provided for @serviceWaitingNow.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting now'**
  String serviceWaitingNow(Object count);

  /// No description provided for @serviceEstWait.
  ///
  /// In en, this message translates to:
  /// **'Est. wait'**
  String get serviceEstWait;

  /// No description provided for @serviceJoinQueue.
  ///
  /// In en, this message translates to:
  /// **'Join this queue'**
  String get serviceJoinQueue;

  /// No description provided for @serviceAbout.
  ///
  /// In en, this message translates to:
  /// **'About this service'**
  String get serviceAbout;

  /// No description provided for @serviceWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get serviceWorkingHours;

  /// No description provided for @serviceTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get serviceTapHint;

  /// No description provided for @branchMain.
  ///
  /// In en, this message translates to:
  /// **'Main branch'**
  String get branchMain;

  /// No description provided for @branchDowntown.
  ///
  /// In en, this message translates to:
  /// **'Downtown branch'**
  String get branchDowntown;

  /// No description provided for @branchNorth.
  ///
  /// In en, this message translates to:
  /// **'North branch'**
  String get branchNorth;

  /// No description provided for @branchAirport.
  ///
  /// In en, this message translates to:
  /// **'Airport branch'**
  String get branchAirport;

  /// No description provided for @branchWest.
  ///
  /// In en, this message translates to:
  /// **'West branch'**
  String get branchWest;

  /// No description provided for @allServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services near you'**
  String get allServicesTitle;

  /// No description provided for @allServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live queues around you'**
  String get allServicesSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @popService.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popService;

  /// No description provided for @mapLocate.
  ///
  /// In en, this message translates to:
  /// **'Locate me'**
  String get mapLocate;

  /// No description provided for @mapLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get mapLocating;

  /// No description provided for @mapLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location is off or permission is denied.'**
  String get mapLocationUnavailable;

  /// No description provided for @mapYouAreHere.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get mapYouAreHere;

  /// No description provided for @mapDistanceAway.
  ///
  /// In en, this message translates to:
  /// **'{km} away'**
  String mapDistanceAway(Object km);

  /// No description provided for @mapDriveTime.
  ///
  /// In en, this message translates to:
  /// **'~{min} min drive'**
  String mapDriveTime(Object min);

  /// No description provided for @mapOpenInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get mapOpenInGoogleMaps;

  /// No description provided for @mapOpenInAppleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Apple Maps'**
  String get mapOpenInAppleMaps;

  /// No description provided for @mapDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get mapDirections;

  /// No description provided for @geoFrom.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get geoFrom;

  /// No description provided for @geoTo.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get geoTo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
