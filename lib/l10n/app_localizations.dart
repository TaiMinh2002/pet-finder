import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PetFinder'**
  String get appTitle;

  /// No description provided for @splashWelcome.
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO'**
  String get splashWelcome;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Reuniting families with their beloved pets'**
  String get splashTagline;

  /// No description provided for @splashDogs.
  ///
  /// In en, this message translates to:
  /// **'Dogs'**
  String get splashDogs;

  /// No description provided for @splashCats.
  ///
  /// In en, this message translates to:
  /// **'Cats'**
  String get splashCats;

  /// No description provided for @splashBirds.
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get splashBirds;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Community Board'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Share lost & found pet posts with your local community'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Map & Location'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Discover nearby lost pets on an interactive map'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Help Together'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Every post brings a furry friend one step closer to home'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back! 👋'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the pet community'**
  String get registerSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get hasAccount;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get tabPosts;

  /// No description provided for @tabCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tabCreate;

  /// No description provided for @tabNotifications.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get tabNotifications;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get filterLost;

  /// No description provided for @filterFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get filterFound;

  /// No description provided for @filterResolved.
  ///
  /// In en, this message translates to:
  /// **'Reunited'**
  String get filterResolved;

  /// No description provided for @postTypeLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get postTypeLost;

  /// No description provided for @postTypeFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get postTypeFound;

  /// No description provided for @postTypeResolved.
  ///
  /// In en, this message translates to:
  /// **'Reunited'**
  String get postTypeResolved;

  /// No description provided for @petTypeDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get petTypeDog;

  /// No description provided for @petTypeCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get petTypeCat;

  /// No description provided for @petTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get petTypeOther;

  /// No description provided for @createPostTitle.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get createPostTitle;

  /// No description provided for @stepPetInfo.
  ///
  /// In en, this message translates to:
  /// **'Pet Info'**
  String get stepPetInfo;

  /// No description provided for @stepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stepLocation;

  /// No description provided for @stepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get stepPhotos;

  /// No description provided for @stepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get stepContact;

  /// No description provided for @petName.
  ///
  /// In en, this message translates to:
  /// **'Pet Name'**
  String get petName;

  /// No description provided for @petNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Buddy'**
  String get petNameHint;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @breedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Golden Retriever'**
  String get breedHint;

  /// No description provided for @colorFeatures.
  ///
  /// In en, this message translates to:
  /// **'Color / Features'**
  String get colorFeatures;

  /// No description provided for @colorFeaturesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. White with orange spots'**
  String get colorFeaturesHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the situation in detail...'**
  String get descriptionHint;

  /// No description provided for @lostDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get lostDate;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @tapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to select on map'**
  String get tapToSelectLocation;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @addPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 photos'**
  String get addPhotosHint;

  /// No description provided for @contactMethod.
  ///
  /// In en, this message translates to:
  /// **'Contact via'**
  String get contactMethod;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// No description provided for @contactZalo.
  ///
  /// In en, this message translates to:
  /// **'Zalo'**
  String get contactZalo;

  /// No description provided for @contactBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get contactBoth;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get phoneNumberHint;

  /// No description provided for @postAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Post anonymously'**
  String get postAnonymously;

  /// No description provided for @publishPost.
  ///
  /// In en, this message translates to:
  /// **'Publish Post'**
  String get publishPost;

  /// No description provided for @selectPetType.
  ///
  /// In en, this message translates to:
  /// **'Select pet type'**
  String get selectPetType;

  /// No description provided for @selectPostType.
  ///
  /// In en, this message translates to:
  /// **'Select post type'**
  String get selectPostType;

  /// No description provided for @postDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get postDetailTitle;

  /// No description provided for @contactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactOwner;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sharePost;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @postedAt.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get postedAt;

  /// No description provided for @markAsResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Reunited'**
  String get markAsResolved;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified when pets are found near you'**
  String get notificationsEmptyHint;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsRadius.
  ///
  /// In en, this message translates to:
  /// **'Search Radius'**
  String get settingsRadius;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About PetFinder'**
  String get settingsAbout;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @languageVi.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVi;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Pets'**
  String get mapTitle;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get mapMyLocation;

  /// No description provided for @mapSearchThisArea.
  ///
  /// In en, this message translates to:
  /// **'Search this area'**
  String get mapSearchThisArea;

  /// No description provided for @mapNoPetsNearby.
  ///
  /// In en, this message translates to:
  /// **'No pets found nearby'**
  String get mapNoPetsNearby;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @emptyPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get emptyPosts;

  /// No description provided for @emptyPostsHint.
  ///
  /// In en, this message translates to:
  /// **'Be the first to post a lost or found pet!'**
  String get emptyPostsHint;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMismatch;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get errorNameRequired;

  /// No description provided for @errorDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get errorDescriptionRequired;

  /// No description provided for @errorLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map'**
  String get errorLocationRequired;

  /// No description provided for @errorPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get errorPhoneRequired;

  /// No description provided for @successPostCreated.
  ///
  /// In en, this message translates to:
  /// **'Post published successfully! 🎉'**
  String get successPostCreated;

  /// No description provided for @successSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get successSignedOut;

  /// No description provided for @successProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get successProfileUpdated;

  /// No description provided for @errorWaitForUpload.
  ///
  /// In en, this message translates to:
  /// **'Please wait for photos to finish uploading'**
  String get errorWaitForUpload;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @loginHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in\nto your account'**
  String get loginHeaderTitle;

  /// No description provided for @loginHeaderEyebrow.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get loginHeaderEyebrow;

  /// No description provided for @loginHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thousands of pets are waiting\nfor you to help them home'**
  String get loginHeaderSubtitle;

  /// No description provided for @loginOnlineMembers.
  ///
  /// In en, this message translates to:
  /// **'12.400 members online'**
  String get loginOnlineMembers;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get loginOrContinueWith;

  /// No description provided for @onboardingLabel1.
  ///
  /// In en, this message translates to:
  /// **'1 / 3'**
  String get onboardingLabel1;

  /// No description provided for @onboardingTitle1Data.
  ///
  /// In en, this message translates to:
  /// **'Lost pets will\nbe found'**
  String get onboardingTitle1Data;

  /// No description provided for @onboardingSubtitle1Data.
  ///
  /// In en, this message translates to:
  /// **'Post in 30 seconds. Thousands of eyes are searching with you.'**
  String get onboardingSubtitle1Data;

  /// No description provided for @onboardingLabel2.
  ///
  /// In en, this message translates to:
  /// **'2 / 3'**
  String get onboardingLabel2;

  /// No description provided for @onboardingTitle2Data.
  ///
  /// In en, this message translates to:
  /// **'Smart map\nnear you'**
  String get onboardingTitle2Data;

  /// No description provided for @onboardingSubtitle2Data.
  ///
  /// In en, this message translates to:
  /// **'See nearby lost pet reports around you in real time.'**
  String get onboardingSubtitle2Data;

  /// No description provided for @onboardingLabel3.
  ///
  /// In en, this message translates to:
  /// **'3 / 3'**
  String get onboardingLabel3;

  /// No description provided for @onboardingTitle3Data.
  ///
  /// In en, this message translates to:
  /// **'Pet-loving\ncommunity helps'**
  String get onboardingTitle3Data;

  /// No description provided for @onboardingSubtitle3Data.
  ///
  /// In en, this message translates to:
  /// **'Connect with tens of thousands of animal lovers ready to help.'**
  String get onboardingSubtitle3Data;

  /// No description provided for @postListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your pet'**
  String get postListSubtitle;

  /// No description provided for @createPostStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String createPostStep(Object current, Object total);

  /// No description provided for @photosUploaded.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s) uploaded'**
  String photosUploaded(Object count);

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for pets'**
  String get settingsMadeWith;

  /// No description provided for @cardTypeLost.
  ///
  /// In en, this message translates to:
  /// **'LOST'**
  String get cardTypeLost;

  /// No description provided for @cardTypeFound.
  ///
  /// In en, this message translates to:
  /// **'FOUND'**
  String get cardTypeFound;

  /// No description provided for @cardTypeResolved.
  ///
  /// In en, this message translates to:
  /// **'REUNITED'**
  String get cardTypeResolved;

  /// No description provided for @cardPetDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get cardPetDog;

  /// No description provided for @cardPetCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get cardPetCat;

  /// No description provided for @cardPetOther.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get cardPetOther;

  /// No description provided for @painterSpotted.
  ///
  /// In en, this message translates to:
  /// **'Spotted near you!'**
  String get painterSpotted;

  /// No description provided for @painterDistance.
  ///
  /// In en, this message translates to:
  /// **'350m away • 5 mins ago'**
  String get painterDistance;

  /// No description provided for @painterMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get painterMembers;

  /// No description provided for @painterFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get painterFound;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
