import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SFE Biodiversité'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FLORAI'**
  String get appName;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

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

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Sign up'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get hasAccount;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'6 characters minimum'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @identifyPlant.
  ///
  /// In en, this message translates to:
  /// **'Identify a Plant'**
  String get identifyPlant;

  /// No description provided for @identifyPlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Identify a plant'**
  String get identifyPlantTitle;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @useCameraOrGallery.
  ///
  /// In en, this message translates to:
  /// **'Use camera or gallery'**
  String get useCameraOrGallery;

  /// No description provided for @aiIdentification.
  ///
  /// In en, this message translates to:
  /// **'AI Identification'**
  String get aiIdentification;

  /// No description provided for @plantNetAnalyzes.
  ///
  /// In en, this message translates to:
  /// **'PlantNet analyzes the plant'**
  String get plantNetAnalyzes;

  /// No description provided for @detailedResults.
  ///
  /// In en, this message translates to:
  /// **'Detailed results'**
  String get detailedResults;

  /// No description provided for @nameDistributionTranslations.
  ///
  /// In en, this message translates to:
  /// **'Name, distribution, translations'**
  String get nameDistributionTranslations;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @clearPhoto.
  ///
  /// In en, this message translates to:
  /// **'Clear photo'**
  String get clearPhoto;

  /// No description provided for @photoSelected.
  ///
  /// In en, this message translates to:
  /// **'Photo selected'**
  String get photoSelected;

  /// No description provided for @compressingImage.
  ///
  /// In en, this message translates to:
  /// **'📸 Compressing image...'**
  String get compressingImage;

  /// No description provided for @sendingToPlantNet.
  ///
  /// In en, this message translates to:
  /// **'🌿 Sending to PlantNet...'**
  String get sendingToPlantNet;

  /// No description provided for @fetchingDistribution.
  ///
  /// In en, this message translates to:
  /// **'🗺️ Fetching distribution...'**
  String get fetchingDistribution;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @beFirstToShare.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share a discovery!'**
  String get beFirstToShare;

  /// No description provided for @failedToLoadFeed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed posts'**
  String get failedToLoadFeed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Identification confidence'**
  String get confidence;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @scientificName.
  ///
  /// In en, this message translates to:
  /// **'Scientific name'**
  String get scientificName;

  /// No description provided for @darija.
  ///
  /// In en, this message translates to:
  /// **'Darija'**
  String get darija;

  /// No description provided for @tamazight.
  ///
  /// In en, this message translates to:
  /// **'Tamazight'**
  String get tamazight;

  /// No description provided for @noTranslationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No translation available'**
  String get noTranslationAvailable;

  /// No description provided for @namesAvailable.
  ///
  /// In en, this message translates to:
  /// **'names available'**
  String get namesAvailable;

  /// No description provided for @proposeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Propose a Darija / Tamazight translation'**
  String get proposeTranslation;

  /// No description provided for @shareWithCommunity.
  ///
  /// In en, this message translates to:
  /// **'Share with community'**
  String get shareWithCommunity;

  /// No description provided for @newPhoto.
  ///
  /// In en, this message translates to:
  /// **'New photo'**
  String get newPhoto;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get location;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @noPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'No personal information added.'**
  String get noPersonalInfo;

  /// No description provided for @max50Chars.
  ///
  /// In en, this message translates to:
  /// **'Max 50 characters'**
  String get max50Chars;

  /// No description provided for @max100Chars.
  ///
  /// In en, this message translates to:
  /// **'Max 100 characters'**
  String get max100Chars;

  /// No description provided for @max500Chars.
  ///
  /// In en, this message translates to:
  /// **'Max 500 characters'**
  String get max500Chars;

  /// No description provided for @myHistory.
  ///
  /// In en, this message translates to:
  /// **'My history'**
  String get myHistory;

  /// No description provided for @allYourIdentifications.
  ///
  /// In en, this message translates to:
  /// **'All your identifications'**
  String get allYourIdentifications;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @contributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get contributions;

  /// No description provided for @identifications.
  ///
  /// In en, this message translates to:
  /// **'Identifications'**
  String get identifications;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading'**
  String get loadingError;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @loadingProfileError.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get loadingProfileError;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmpty;

  /// No description provided for @willSeeNotificationsHere.
  ///
  /// In en, this message translates to:
  /// **'You will see your notifications here'**
  String get willSeeNotificationsHere;

  /// No description provided for @cannotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Cannot load notifications'**
  String get cannotLoadNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @failedToMarkAsRead.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as read'**
  String get failedToMarkAsRead;

  /// No description provided for @failedToMarkAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark all as read'**
  String get failedToMarkAllAsRead;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete notification'**
  String get failedToDelete;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No description provided for @flagPost.
  ///
  /// In en, this message translates to:
  /// **'Flag Post'**
  String get flagPost;

  /// No description provided for @areYouSureFlag.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to flag this post?'**
  String get areYouSureFlag;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @flag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flag;

  /// No description provided for @communityFeed.
  ///
  /// In en, this message translates to:
  /// **'Community Feed'**
  String get communityFeed;

  /// No description provided for @allPosts.
  ///
  /// In en, this message translates to:
  /// **'All Posts'**
  String get allPosts;

  /// No description provided for @translationSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Translation Suggestions'**
  String get translationSuggestions;

  /// No description provided for @plantOfDay.
  ///
  /// In en, this message translates to:
  /// **'Plant of the Day'**
  String get plantOfDay;

  /// No description provided for @failedToLikePost.
  ///
  /// In en, this message translates to:
  /// **'Failed to like post'**
  String get failedToLikePost;

  /// No description provided for @failedToFlagPost.
  ///
  /// In en, this message translates to:
  /// **'Failed to flag post'**
  String get failedToFlagPost;

  /// No description provided for @approvedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Approved by admin'**
  String get approvedByAdmin;

  /// No description provided for @identification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get identification;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @plantOfDayShort.
  ///
  /// In en, this message translates to:
  /// **'Plant of Day'**
  String get plantOfDayShort;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @voteRecorded.
  ///
  /// In en, this message translates to:
  /// **'Vote recorded'**
  String get voteRecorded;

  /// No description provided for @errorVoting.
  ///
  /// In en, this message translates to:
  /// **'Error voting'**
  String get errorVoting;

  /// No description provided for @errorLikingPost.
  ///
  /// In en, this message translates to:
  /// **'Error liking post'**
  String get errorLikingPost;

  /// No description provided for @shareDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Share Discovery'**
  String get shareDiscovery;

  /// No description provided for @shareYourDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Share your discovery?'**
  String get shareYourDiscovery;

  /// No description provided for @postAs.
  ///
  /// In en, this message translates to:
  /// **'Post as:'**
  String get postAs;

  /// No description provided for @moroccoOnly.
  ///
  /// In en, this message translates to:
  /// **'Morocco only'**
  String get moroccoOnly;

  /// No description provided for @cityLevel.
  ///
  /// In en, this message translates to:
  /// **'City level'**
  String get cityLevel;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get noLocation;

  /// No description provided for @showOnlyCountryLevel.
  ///
  /// In en, this message translates to:
  /// **'Show only country level'**
  String get showOnlyCountryLevel;

  /// No description provided for @showYourSpecificCity.
  ///
  /// In en, this message translates to:
  /// **'Show your specific city'**
  String get showYourSpecificCity;

  /// No description provided for @hideLocationCompletely.
  ///
  /// In en, this message translates to:
  /// **'Hide location completely'**
  String get hideLocationCompletely;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @detectingYourCity.
  ///
  /// In en, this message translates to:
  /// **'Detecting your city...'**
  String get detectingYourCity;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @detectedCity.
  ///
  /// In en, this message translates to:
  /// **'Detected city:'**
  String get detectedCity;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @yourCountryIsAlwaysShownForContext.
  ///
  /// In en, this message translates to:
  /// **'Your country is always shown for context'**
  String get yourCountryIsAlwaysShownForContext;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sharingToCommunity.
  ///
  /// In en, this message translates to:
  /// **'Sharing to community...'**
  String get sharingToCommunity;

  /// No description provided for @discoveryPosted.
  ///
  /// In en, this message translates to:
  /// **'Discovery Posted!'**
  String get discoveryPosted;

  /// No description provided for @yourDiscoveryHasBeenPosted.
  ///
  /// In en, this message translates to:
  /// **'Your discovery has been posted'**
  String get yourDiscoveryHasBeenPosted;

  /// No description provided for @anonymously.
  ///
  /// In en, this message translates to:
  /// **'anonymously'**
  String get anonymously;

  /// No description provided for @as.
  ///
  /// In en, this message translates to:
  /// **'as'**
  String get as;

  /// No description provided for @andWillBeVisibleToTheCommunity.
  ///
  /// In en, this message translates to:
  /// **'and will be visible to the community.'**
  String get andWillBeVisibleToTheCommunity;

  /// No description provided for @failedToShareDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Failed to share discovery'**
  String get failedToShareDiscovery;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
