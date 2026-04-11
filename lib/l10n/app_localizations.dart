import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Picksy'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get navPro;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @generatorColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get generatorColor;

  /// No description provided for @generatorNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get generatorNumber;

  /// No description provided for @generatorCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get generatorCoin;

  /// No description provided for @generatorLetter.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get generatorLetter;

  /// No description provided for @generatorCustomList.
  ///
  /// In en, this message translates to:
  /// **'Custom List'**
  String get generatorCustomList;

  /// No description provided for @generatorBottleSpin.
  ///
  /// In en, this message translates to:
  /// **'Bottle Spin'**
  String get generatorBottleSpin;

  /// No description provided for @generatorTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get generatorTime;

  /// No description provided for @generatorReactionTest.
  ///
  /// In en, this message translates to:
  /// **'Reaction Test'**
  String get generatorReactionTest;

  /// No description provided for @generatorHangman.
  ///
  /// In en, this message translates to:
  /// **'Hangman'**
  String get generatorHangman;

  /// No description provided for @generatorMemoryFlash.
  ///
  /// In en, this message translates to:
  /// **'Memory Flash'**
  String get generatorMemoryFlash;

  /// No description provided for @generatorTapChallenge.
  ///
  /// In en, this message translates to:
  /// **'Tap Challenge'**
  String get generatorTapChallenge;

  /// No description provided for @generatorMathChallenge.
  ///
  /// In en, this message translates to:
  /// **'Math Challenge'**
  String get generatorMathChallenge;

  /// No description provided for @commonGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get commonGenerate;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonProFeature.
  ///
  /// In en, this message translates to:
  /// **'Pro feature'**
  String get commonProFeature;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get settingsReportBug;

  /// No description provided for @settingsSuggestFeature.
  ///
  /// In en, this message translates to:
  /// **'Suggest Feature'**
  String get settingsSuggestFeature;

  /// No description provided for @settingsSupportPicksy.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get settingsSupportPicksy;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsImprint.
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get settingsImprint;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsRequiresGithub.
  ///
  /// In en, this message translates to:
  /// **'Requires a GitHub account'**
  String get settingsRequiresGithub;

  /// No description provided for @settingsProActive.
  ///
  /// In en, this message translates to:
  /// **'Pro active'**
  String get settingsProActive;

  /// No description provided for @settingsFreeVersion.
  ///
  /// In en, this message translates to:
  /// **'Free version'**
  String get settingsFreeVersion;

  /// No description provided for @settingsLangEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEnglish;

  /// No description provided for @settingsLangGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get settingsLangGerman;

  /// No description provided for @settingsLangSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLangSpanish;

  /// No description provided for @settingsLangFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get settingsLangFrench;

  /// No description provided for @settingsLangItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get settingsLangItalian;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get settingsRateApp;

  /// No description provided for @settingsShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get settingsShareApp;

  /// No description provided for @settingsShareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends to try Picksy'**
  String get settingsShareAppSubtitle;

  /// No description provided for @settingsCompareFreePro.
  ///
  /// In en, this message translates to:
  /// **'Compare Free vs Pro'**
  String get settingsCompareFreePro;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedback;

  /// No description provided for @settingsAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get settingsAppStore;

  /// No description provided for @settingsProSection.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get settingsProSection;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Free vs Pro'**
  String get compareTitle;

  /// No description provided for @compareFeatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get compareFeatureLabel;

  /// No description provided for @compareFreeColumn.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get compareFreeColumn;

  /// No description provided for @compareProColumn.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get compareProColumn;

  /// No description provided for @compareFeatureHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get compareFeatureHistory;

  /// No description provided for @compareFreeHistory.
  ///
  /// In en, this message translates to:
  /// **'3 results'**
  String get compareFreeHistory;

  /// No description provided for @compareProHistory.
  ///
  /// In en, this message translates to:
  /// **'1000 results'**
  String get compareProHistory;

  /// No description provided for @compareFeatureFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get compareFeatureFavorites;

  /// No description provided for @compareFreeFavorites.
  ///
  /// In en, this message translates to:
  /// **'Up to 2'**
  String get compareFreeFavorites;

  /// No description provided for @compareProFavorites.
  ///
  /// In en, this message translates to:
  /// **'Up to 999'**
  String get compareProFavorites;

  /// No description provided for @compareFeatureColorModes.
  ///
  /// In en, this message translates to:
  /// **'Color Features'**
  String get compareFeatureColorModes;

  /// No description provided for @compareFeatureCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Number Features'**
  String get compareFeatureCustomRange;

  /// No description provided for @compareFeatureCustomListExtras.
  ///
  /// In en, this message translates to:
  /// **'Custom List'**
  String get compareFeatureCustomListExtras;

  /// No description provided for @compareFeatureTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Timer Range'**
  String get compareFeatureTimeRange;

  /// No description provided for @compareFeatureLetterFilters.
  ///
  /// In en, this message translates to:
  /// **'Letter Filters'**
  String get compareFeatureLetterFilters;

  /// No description provided for @compareFeatureBottleHaptics.
  ///
  /// In en, this message translates to:
  /// **'Bottle Spin Controls'**
  String get compareFeatureBottleHaptics;

  /// No description provided for @compareFeatureAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get compareFeatureAnalytics;

  /// No description provided for @proPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get proPromoCode;

  /// No description provided for @proPromoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get proPromoCodeHint;

  /// No description provided for @proPromoCodeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get proPromoCodeApply;

  /// No description provided for @proPromoCodeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied! Pro is now active.'**
  String get proPromoCodeSuccess;

  /// No description provided for @proPromoCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code. Please try again.'**
  String get proPromoCodeInvalid;

  /// No description provided for @homeSmartRandomDecisions.
  ///
  /// In en, this message translates to:
  /// **'Smart random decisions'**
  String get homeSmartRandomDecisions;

  /// No description provided for @homeHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeHistoryTooltip;

  /// No description provided for @homeFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeFavorites;

  /// No description provided for @homeAllGenerators.
  ///
  /// In en, this message translates to:
  /// **'All Generators'**
  String get homeAllGenerators;

  /// No description provided for @homeTabGenerators.
  ///
  /// In en, this message translates to:
  /// **'Generators'**
  String get homeTabGenerators;

  /// No description provided for @homeTabMiniGames.
  ///
  /// In en, this message translates to:
  /// **'Mini Games'**
  String get homeTabMiniGames;

  /// No description provided for @homeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get homeFavorite;

  /// No description provided for @homeUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get homeUnfavorite;

  /// No description provided for @homeTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get homeTapToOpen;

  /// No description provided for @homeFavoritesLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites limit reached'**
  String get homeFavoritesLimitReachedTitle;

  /// No description provided for @homeFavoritesLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Free users can pin up to 2 generators. Go Pro for unlimited favorites.'**
  String get homeFavoritesLimitReachedMessage;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get historyClearAll;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmpty;

  /// No description provided for @historyItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{generator} • {timestamp}'**
  String historyItemSubtitle(Object generator, Object timestamp);

  /// No description provided for @routerComingNext.
  ///
  /// In en, this message translates to:
  /// **'Coming next: {generator}'**
  String routerComingNext(Object generator);

  /// No description provided for @gateNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get gateNotNow;

  /// No description provided for @gateGoPro.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get gateGoPro;

  /// No description provided for @gateOpenProTab.
  ///
  /// In en, this message translates to:
  /// **'Open Pro tab to upgrade'**
  String get gateOpenProTab;

  /// No description provided for @proGoPro.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get proGoPro;

  /// No description provided for @proActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO ACTIVE'**
  String get proActiveBadge;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @proThanksActive.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Pro is active on this device.'**
  String get proThanksActive;

  /// No description provided for @proUnlockDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pro features: more history, unlimited favorites, and advanced generators.'**
  String get proUnlockDescription;

  /// No description provided for @proIapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are not available on this device/platform.\nTip: IAP works on Android/iOS when installed via the store test track.'**
  String get proIapUnavailable;

  /// No description provided for @proWhatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What you get with Pro'**
  String get proWhatYouGet;

  /// No description provided for @proFeatureHistory.
  ///
  /// In en, this message translates to:
  /// **'History: 1000 results (Free: 3)'**
  String get proFeatureHistory;

  /// No description provided for @proFeatureFavorites.
  ///
  /// In en, this message translates to:
  /// **'Unlimited favorites (Free: 2)'**
  String get proFeatureFavorites;

  /// No description provided for @proFeatureNumber.
  ///
  /// In en, this message translates to:
  /// **'Number: custom min/max + float + even/odd'**
  String get proFeatureNumber;

  /// No description provided for @proFeatureGames.
  ///
  /// In en, this message translates to:
  /// **'Unlimited games: play as much as you want (Free: 10/day)'**
  String get proFeatureGames;

  /// No description provided for @proFeatureLetter.
  ///
  /// In en, this message translates to:
  /// **'Letter: lowercase + umlauts + vowels + exclude'**
  String get proFeatureLetter;

  /// No description provided for @proFeatureCustomList.
  ///
  /// In en, this message translates to:
  /// **'Custom List: undo + weighted (V1)'**
  String get proFeatureCustomList;

  /// No description provided for @proFeatureBottleSpin.
  ///
  /// In en, this message translates to:
  /// **'Bottle Spin: strength + haptics'**
  String get proFeatureBottleSpin;

  /// No description provided for @proChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get proChoosePlan;

  /// No description provided for @proMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Monthly'**
  String get proMonthlyTitle;

  /// No description provided for @proMonthlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best if you want to try it out'**
  String get proMonthlySubtitle;

  /// No description provided for @proLifetimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Unlock'**
  String get proLifetimeTitle;

  /// No description provided for @proLifetimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay once, keep Pro forever'**
  String get proLifetimeSubtitle;

  /// No description provided for @proPopular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get proPopular;

  /// No description provided for @proUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get proUnlockButton;

  /// No description provided for @proActiveButton.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get proActiveButton;

  /// No description provided for @proRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get proRestorePurchases;

  /// No description provided for @proPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Privacy: No account required. All data stays on your device.'**
  String get proPrivacyNote;

  /// No description provided for @proPaymentsNote.
  ///
  /// In en, this message translates to:
  /// **'Payments and restore are handled via your Apple/Google store account.'**
  String get proPaymentsNote;

  /// No description provided for @proMonthlyFallbackPrice.
  ///
  /// In en, this message translates to:
  /// **'€0.49 / month'**
  String get proMonthlyFallbackPrice;

  /// No description provided for @proLifetimeFallbackPrice.
  ///
  /// In en, this message translates to:
  /// **'€5.49 one-time'**
  String get proLifetimeFallbackPrice;

  /// No description provided for @coinTitle.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get coinTitle;

  /// No description provided for @coinFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get coinFlip;

  /// No description provided for @coinDefaultHeads.
  ///
  /// In en, this message translates to:
  /// **'Heads'**
  String get coinDefaultHeads;

  /// No description provided for @coinDefaultTails.
  ///
  /// In en, this message translates to:
  /// **'Tails'**
  String get coinDefaultTails;

  /// No description provided for @colorTitle.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorTitle;

  /// No description provided for @letterTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get letterTitle;

  /// No description provided for @letterExcludeLetters.
  ///
  /// In en, this message translates to:
  /// **'Exclude letters'**
  String get letterExcludeLetters;

  /// No description provided for @letterExcludeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get letterExcludeNone;

  /// No description provided for @letterFiltersProTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter filters are Pro'**
  String get letterFiltersProTitle;

  /// No description provided for @letterFiltersProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to unlock lowercase, umlauts, vowels-only, and exclusions.'**
  String get letterFiltersProMessage;

  /// No description provided for @numberTitle.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get numberTitle;

  /// No description provided for @numberTapGenerate.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Generate\" to get a number'**
  String get numberTapGenerate;

  /// No description provided for @numberSectionRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get numberSectionRange;

  /// No description provided for @numberSectionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get numberSectionType;

  /// No description provided for @numberSectionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get numberSectionFilter;

  /// No description provided for @numberInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Max must be >= Min'**
  String get numberInvalidRange;

  /// No description provided for @numberFloat.
  ///
  /// In en, this message translates to:
  /// **'Float (decimals)'**
  String get numberFloat;

  /// No description provided for @numberFloatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate decimal numbers'**
  String get numberFloatSubtitle;

  /// No description provided for @numberCustomRangeProTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom range is Pro'**
  String get numberCustomRangeProTitle;

  /// No description provided for @numberCustomRangeProMessage.
  ///
  /// In en, this message translates to:
  /// **'Free users can generate numbers from 0 to 100. Go Pro to set your own min/max.'**
  String get numberCustomRangeProMessage;

  /// No description provided for @numberFloatProTitle.
  ///
  /// In en, this message translates to:
  /// **'Float mode is Pro'**
  String get numberFloatProTitle;

  /// No description provided for @numberFloatProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to generate decimal numbers.'**
  String get numberFloatProMessage;

  /// No description provided for @numberParityProTitle.
  ///
  /// In en, this message translates to:
  /// **'Even/Odd filter is Pro'**
  String get numberParityProTitle;

  /// No description provided for @numberParityProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to filter for even or odd numbers.'**
  String get numberParityProMessage;

  /// No description provided for @numberParityAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get numberParityAny;

  /// No description provided for @numberParityEven.
  ///
  /// In en, this message translates to:
  /// **'Even'**
  String get numberParityEven;

  /// No description provided for @numberParityOdd.
  ///
  /// In en, this message translates to:
  /// **'Odd'**
  String get numberParityOdd;

  /// No description provided for @numberMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get numberMin;

  /// No description provided for @numberMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get numberMax;

  /// No description provided for @numberFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free limits: range 0-100, integer only.\nGo Pro for custom range, floats, and even/odd filters.'**
  String get numberFreeProHint;

  /// No description provided for @customListTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom List'**
  String get customListTitle;

  /// No description provided for @customListNewList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get customListNewList;

  /// No description provided for @customListSelectList.
  ///
  /// In en, this message translates to:
  /// **'Select list'**
  String get customListSelectList;

  /// No description provided for @customListDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get customListDeleteList;

  /// No description provided for @customListWithReplacement.
  ///
  /// In en, this message translates to:
  /// **'With replacement'**
  String get customListWithReplacement;

  /// No description provided for @customListWithReplacementOn.
  ///
  /// In en, this message translates to:
  /// **'Picked item stays in the list'**
  String get customListWithReplacementOn;

  /// No description provided for @customListWithReplacementOff.
  ///
  /// In en, this message translates to:
  /// **'Picked item is removed (auto resets when empty)'**
  String get customListWithReplacementOff;

  /// No description provided for @customListTeamMode.
  ///
  /// In en, this message translates to:
  /// **'Team mode'**
  String get customListTeamMode;

  /// No description provided for @customListTeamModeOn.
  ///
  /// In en, this message translates to:
  /// **'Generate teams from all list items'**
  String get customListTeamModeOn;

  /// No description provided for @customListTeamModeOff.
  ///
  /// In en, this message translates to:
  /// **'Pick one random item'**
  String get customListTeamModeOff;

  /// No description provided for @customListTeamsLabel.
  ///
  /// In en, this message translates to:
  /// **'Teams:'**
  String get customListTeamsLabel;

  /// No description provided for @customListPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String customListPeopleCount(int count);

  /// No description provided for @customListTeamsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get customListTeamsCardTitle;

  /// No description provided for @customListTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Team {index}'**
  String customListTeamTitle(int index);

  /// No description provided for @customListTeamHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'Team {index}: {members}'**
  String customListTeamHistoryLine(int index, Object members);

  /// No description provided for @customListEmptyTeam.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get customListEmptyTeam;

  /// No description provided for @customListNoItems.
  ///
  /// In en, this message translates to:
  /// **'(no items)'**
  String get customListNoItems;

  /// No description provided for @customListPicked.
  ///
  /// In en, this message translates to:
  /// **'Picked: {value}'**
  String customListPicked(Object value);

  /// No description provided for @customListGenerateTeams.
  ///
  /// In en, this message translates to:
  /// **'Generate Teams'**
  String get customListGenerateTeams;

  /// No description provided for @customListPickRandom.
  ///
  /// In en, this message translates to:
  /// **'Pick Random'**
  String get customListPickRandom;

  /// No description provided for @customListRestoreRemoved.
  ///
  /// In en, this message translates to:
  /// **'Restore removed'**
  String get customListRestoreRemoved;

  /// No description provided for @customListAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get customListAddItem;

  /// No description provided for @customListAddItemHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pizza'**
  String get customListAddItemHint;

  /// No description provided for @customListNoListSelected.
  ///
  /// In en, this message translates to:
  /// **'No list selected'**
  String get customListNoListSelected;

  /// No description provided for @bottleSpinTitle.
  ///
  /// In en, this message translates to:
  /// **'Bottle Spin'**
  String get bottleSpinTitle;

  /// No description provided for @bottleSpinSpinning.
  ///
  /// In en, this message translates to:
  /// **'Spinning...'**
  String get bottleSpinSpinning;

  /// No description provided for @bottleSpinSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get bottleSpinSpin;

  /// No description provided for @bottleSpinAngleValue.
  ///
  /// In en, this message translates to:
  /// **'Angle: {degree}°'**
  String bottleSpinAngleValue(Object degree);

  /// No description provided for @timeTitle.
  ///
  /// In en, this message translates to:
  /// **'Random Time'**
  String get timeTitle;

  /// No description provided for @timeReady.
  ///
  /// In en, this message translates to:
  /// **'Ready?'**
  String get timeReady;

  /// No description provided for @timeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timeReset;

  /// No description provided for @timeAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get timeAgain;

  /// No description provided for @timeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timeStart;

  /// No description provided for @timeStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timeStop;

  /// No description provided for @timeHideTime.
  ///
  /// In en, this message translates to:
  /// **'Hide time'**
  String get timeHideTime;

  /// No description provided for @timeRangeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Range (seconds)'**
  String get timeRangeSeconds;

  /// No description provided for @timeRunning.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get timeRunning;

  /// No description provided for @timeHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get timeHidden;

  /// No description provided for @timeFormatted.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s {milliseconds}ms'**
  String timeFormatted(int seconds, Object milliseconds);

  /// No description provided for @hangmanTitle.
  ///
  /// In en, this message translates to:
  /// **'Hangman'**
  String get hangmanTitle;

  /// No description provided for @hangmanDescription.
  ///
  /// In en, this message translates to:
  /// **'Guess the word letter by letter'**
  String get hangmanDescription;

  /// No description provided for @hangmanNewGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get hangmanNewGame;

  /// No description provided for @hangmanPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get hangmanPlayAgain;

  /// No description provided for @hangmanYouWon.
  ///
  /// In en, this message translates to:
  /// **'You won!'**
  String get hangmanYouWon;

  /// No description provided for @hangmanYouLost.
  ///
  /// In en, this message translates to:
  /// **'Game over! The word was: {word}'**
  String hangmanYouLost(Object word);

  /// No description provided for @hangmanAttemptsLeft.
  ///
  /// In en, this message translates to:
  /// **'Attempts left: {count}'**
  String hangmanAttemptsLeft(int count);

  /// No description provided for @hangmanWrongLetters.
  ///
  /// In en, this message translates to:
  /// **'Wrong letters:'**
  String get hangmanWrongLetters;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsProOnly.
  ///
  /// In en, this message translates to:
  /// **'Analytics is a Pro feature'**
  String get analyticsProOnly;

  /// No description provided for @analyticsProMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced analytics, trends and auto-run with Picksy Pro.'**
  String get analyticsProMessage;

  /// No description provided for @analyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Generate some results first.'**
  String get analyticsEmpty;

  /// No description provided for @analyticsViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get analyticsViewAll;

  /// No description provided for @analyticsGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'{generator} Analytics'**
  String analyticsGeneratorTitle(Object generator);

  /// No description provided for @analyticsAutoRun.
  ///
  /// In en, this message translates to:
  /// **'Auto-Run'**
  String get analyticsAutoRun;

  /// No description provided for @analyticsAutoRunCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get analyticsAutoRunCount;

  /// No description provided for @analyticsAutoRunStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get analyticsAutoRunStart;

  /// No description provided for @analyticsAutoRunRunning.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get analyticsAutoRunRunning;

  /// No description provided for @analyticsAutoRunResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get analyticsAutoRunResults;

  /// No description provided for @analyticsAutoRunDistribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get analyticsAutoRunDistribution;

  /// No description provided for @analyticsBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get analyticsBestTime;

  /// No description provided for @analyticsAvgTime.
  ///
  /// In en, this message translates to:
  /// **'Avg time'**
  String get analyticsAvgTime;

  /// No description provided for @analyticsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get analyticsTotal;

  /// No description provided for @analyticsWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get analyticsWins;

  /// No description provided for @analyticsLosses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get analyticsLosses;

  /// No description provided for @analyticsWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get analyticsWinRate;

  /// No description provided for @analyticsHighScore.
  ///
  /// In en, this message translates to:
  /// **'High score'**
  String get analyticsHighScore;

  /// No description provided for @analyticsFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get analyticsFrequency;

  /// No description provided for @analyticsAvgLevel.
  ///
  /// In en, this message translates to:
  /// **'Avg level'**
  String get analyticsAvgLevel;

  /// No description provided for @analyticsLevelDistribution.
  ///
  /// In en, this message translates to:
  /// **'Level distribution'**
  String get analyticsLevelDistribution;

  /// No description provided for @memoryFlashTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Flash'**
  String get memoryFlashTitle;

  /// No description provided for @memoryFlashDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch the sequence, then repeat it'**
  String get memoryFlashDescription;

  /// No description provided for @memoryFlashStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get memoryFlashStart;

  /// No description provided for @memoryFlashPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get memoryFlashPlayAgain;

  /// No description provided for @memoryFlashBackToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get memoryFlashBackToMenu;

  /// No description provided for @memoryFlashWatchSequence.
  ///
  /// In en, this message translates to:
  /// **'Watch the sequence…'**
  String get memoryFlashWatchSequence;

  /// No description provided for @memoryFlashYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn!'**
  String get memoryFlashYourTurn;

  /// No description provided for @memoryFlashLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String memoryFlashLevel(int level);

  /// No description provided for @memoryFlashGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get memoryFlashGameOver;

  /// No description provided for @memoryFlashResult.
  ///
  /// In en, this message translates to:
  /// **'Level reached: {level}'**
  String memoryFlashResult(int level);

  /// No description provided for @memoryFlashBlocks.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get memoryFlashBlocks;

  /// No description provided for @memoryFlashFlashSpeed.
  ///
  /// In en, this message translates to:
  /// **'Flash speed'**
  String get memoryFlashFlashSpeed;

  /// No description provided for @memoryFlashSpeedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get memoryFlashSpeedSlow;

  /// No description provided for @memoryFlashSpeedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get memoryFlashSpeedNormal;

  /// No description provided for @memoryFlashSpeedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get memoryFlashSpeedFast;

  /// No description provided for @memoryFlashProEndlessTitle.
  ///
  /// In en, this message translates to:
  /// **'Endless mode is Pro'**
  String get memoryFlashProEndlessTitle;

  /// No description provided for @memoryFlashProEndlessMessage.
  ///
  /// In en, this message translates to:
  /// **'Free mode is limited to 10 levels. Go Pro for endless play.'**
  String get memoryFlashProEndlessMessage;

  /// No description provided for @memoryFlashProSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjustable speed is Pro'**
  String get memoryFlashProSpeedTitle;

  /// No description provided for @memoryFlashProSpeedMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to adjust the flash speed.'**
  String get memoryFlashProSpeedMessage;

  /// No description provided for @memoryFlashSequenceLength.
  ///
  /// In en, this message translates to:
  /// **'Sequence: {length}'**
  String memoryFlashSequenceLength(int length);

  /// No description provided for @generatorCard.
  ///
  /// In en, this message translates to:
  /// **'Card Draw'**
  String get generatorCard;

  /// No description provided for @cardTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Draw'**
  String get cardTitle;

  /// No description provided for @cardTapDraw.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Draw\" to draw a card'**
  String get cardTapDraw;

  /// No description provided for @cardDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get cardDraw;

  /// No description provided for @cardSectionOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get cardSectionOptions;

  /// No description provided for @cardIncludeJokers.
  ///
  /// In en, this message translates to:
  /// **'Include Jokers'**
  String get cardIncludeJokers;

  /// No description provided for @cardIncludeJokersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add two Jokers to the deck'**
  String get cardIncludeJokersSubtitle;

  /// No description provided for @cardIncludeJokersProTitle.
  ///
  /// In en, this message translates to:
  /// **'Jokers are Pro'**
  String get cardIncludeJokersProTitle;

  /// No description provided for @cardIncludeJokersProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to add Jokers to the deck.'**
  String get cardIncludeJokersProMessage;

  /// No description provided for @cardMultiDrawCount.
  ///
  /// In en, this message translates to:
  /// **'Cards per draw'**
  String get cardMultiDrawCount;

  /// No description provided for @cardMultiDrawProTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-draw is Pro'**
  String get cardMultiDrawProTitle;

  /// No description provided for @cardMultiDrawProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to draw multiple cards at once.'**
  String get cardMultiDrawProMessage;

  /// No description provided for @cardFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: Single draw.\nPro: Jokers + multi-draw.'**
  String get cardFreeProHint;

  /// No description provided for @analyticsBestAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Best accuracy'**
  String get analyticsBestAccuracy;

  /// No description provided for @analyticsAvgAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Avg accuracy'**
  String get analyticsAvgAccuracy;

  /// No description provided for @generatorColorReflex.
  ///
  /// In en, this message translates to:
  /// **'Color Reflex'**
  String get generatorColorReflex;

  /// No description provided for @colorReflexInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap the color of the TEXT, not the word!'**
  String get colorReflexInstructions;

  /// No description provided for @colorReflexDescription.
  ///
  /// In en, this message translates to:
  /// **'Uses the Stroop Effect to test your reflexes.'**
  String get colorReflexDescription;

  /// No description provided for @colorReflexDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get colorReflexDurationLabel;

  /// No description provided for @colorReflexGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready!'**
  String get colorReflexGetReady;

  /// No description provided for @colorReflexTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the COLOR of the text above'**
  String get colorReflexTapPrompt;

  /// No description provided for @colorReflexTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get colorReflexTimeUp;

  /// No description provided for @colorReflexCorrectLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get colorReflexCorrectLabel;

  /// No description provided for @colorReflexWrongLabel.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get colorReflexWrongLabel;

  /// No description provided for @colorReflexAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get colorReflexAccuracyLabel;

  /// No description provided for @colorReflexAvgReactionLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg reaction'**
  String get colorReflexAvgReactionLabel;

  /// No description provided for @colorReflexPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get colorReflexPlayAgain;

  /// No description provided for @colorReflexBackToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get colorReflexBackToMenu;

  /// No description provided for @colorReflexDurationProTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom duration is Pro'**
  String get colorReflexDurationProTitle;

  /// No description provided for @colorReflexDurationProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to choose between 15s, 30s, and 60s durations.'**
  String get colorReflexDurationProMessage;

  /// No description provided for @colorReflexFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: 30 seconds fixed.\nPro: choose 15s, 30s, or 60s.'**
  String get colorReflexFreeProHint;

  /// No description provided for @tapChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Challenge'**
  String get tapChallengeTitle;

  /// No description provided for @tapChallengeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap as fast as you can when GO appears!'**
  String get tapChallengeInstructions;

  /// No description provided for @tapChallengeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get tapChallengeStart;

  /// No description provided for @tapChallengeAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tapChallengeAgain;

  /// No description provided for @tapChallengeTaps.
  ///
  /// In en, this message translates to:
  /// **'Taps'**
  String get tapChallengeTaps;

  /// No description provided for @tapChallengeTPS.
  ///
  /// In en, this message translates to:
  /// **'Taps/sec'**
  String get tapChallengeTPS;

  /// No description provided for @tapChallengePersonalBest.
  ///
  /// In en, this message translates to:
  /// **'Personal Best'**
  String get tapChallengePersonalBest;

  /// No description provided for @tapChallengeDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get tapChallengeDurationLabel;

  /// No description provided for @tapChallengeDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String tapChallengeDurationSeconds(int seconds);

  /// No description provided for @tapChallengeDurationProTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Duration is Pro'**
  String get tapChallengeDurationProTitle;

  /// No description provided for @tapChallengeDurationProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to set the challenge duration to 5s, 10s, 15s, 30s, or 60s.'**
  String get tapChallengeDurationProMessage;

  /// No description provided for @tapChallengeGo.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get tapChallengeGo;

  /// No description provided for @tapChallengeGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get Ready'**
  String get tapChallengeGetReady;

  /// No description provided for @tapChallengeResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Run Complete!'**
  String get tapChallengeResultTitle;

  /// No description provided for @tapChallengeAnalyticsPersonalBest.
  ///
  /// In en, this message translates to:
  /// **'Best Taps'**
  String get tapChallengeAnalyticsPersonalBest;

  /// No description provided for @tapChallengeAnalyticsAvgTaps.
  ///
  /// In en, this message translates to:
  /// **'Avg Taps'**
  String get tapChallengeAnalyticsAvgTaps;

  /// No description provided for @tapChallengeAnalyticsAvgTPS.
  ///
  /// In en, this message translates to:
  /// **'Avg TPS'**
  String get tapChallengeAnalyticsAvgTPS;

  /// No description provided for @tapChallengeAnalyticsBestTPS.
  ///
  /// In en, this message translates to:
  /// **'Best TPS'**
  String get tapChallengeAnalyticsBestTPS;

  /// No description provided for @mathChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Math Challenge'**
  String get mathChallengeTitle;

  /// No description provided for @mathDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get mathDifficulty;

  /// No description provided for @mathDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get mathDifficultyEasy;

  /// No description provided for @mathDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get mathDifficultyHard;

  /// No description provided for @mathDifficultyProTitle.
  ///
  /// In en, this message translates to:
  /// **'Hard mode is Pro'**
  String get mathDifficultyProTitle;

  /// No description provided for @mathDifficultyProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to unlock multiplication, division and larger numbers.'**
  String get mathDifficultyProMessage;

  /// No description provided for @mathDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get mathDuration;

  /// No description provided for @mathDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String mathDurationSeconds(int seconds);

  /// No description provided for @mathDurationFree.
  ///
  /// In en, this message translates to:
  /// **'Fixed: 30 seconds'**
  String get mathDurationFree;

  /// No description provided for @mathDurationProTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom duration is Pro'**
  String get mathDurationProTitle;

  /// No description provided for @mathDurationProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to select a custom duration from 15 to 60 seconds.'**
  String get mathDurationProMessage;

  /// No description provided for @mathStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get mathStart;

  /// No description provided for @mathTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get mathTimeLeft;

  /// No description provided for @mathCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get mathCorrect;

  /// No description provided for @mathWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get mathWrong;

  /// No description provided for @mathResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get mathResultTitle;

  /// No description provided for @mathAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get mathAccuracy;

  /// No description provided for @mathPPS.
  ///
  /// In en, this message translates to:
  /// **'Per sec'**
  String get mathPPS;

  /// No description provided for @mathPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get mathPlayAgain;

  /// No description provided for @mathBackToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get mathBackToMenu;

  /// No description provided for @mathFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: addition & subtraction, 30 seconds.\nPro: all operations, custom duration.'**
  String get mathFreeProHint;

  /// No description provided for @mathAvgAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Avg Accuracy'**
  String get mathAvgAccuracy;

  /// No description provided for @generatorTicTacToe.
  ///
  /// In en, this message translates to:
  /// **'Tic Tac Toe'**
  String get generatorTicTacToe;

  /// No description provided for @ticTacToeDescription.
  ///
  /// In en, this message translates to:
  /// **'Classic 3×3 game of X\'s and O\'s'**
  String get ticTacToeDescription;

  /// No description provided for @connectFourDescription.
  ///
  /// In en, this message translates to:
  /// **'Classic 7×6 strategy game – connect 4 to win'**
  String get connectFourDescription;

  /// No description provided for @mathChallengeDescription.
  ///
  /// In en, this message translates to:
  /// **'Solve math problems as fast as you can'**
  String get mathChallengeDescription;

  /// No description provided for @generatorConnectFour.
  ///
  /// In en, this message translates to:
  /// **'Connect Four'**
  String get generatorConnectFour;

  /// No description provided for @gameSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Setup'**
  String get gameSetupTitle;

  /// No description provided for @gameModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameModeLabel;

  /// No description provided for @gameModeBot.
  ///
  /// In en, this message translates to:
  /// **'Play vs Bot'**
  String get gameModeBot;

  /// No description provided for @gameModeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local Multiplayer'**
  String get gameModeLocal;

  /// No description provided for @gameModePro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get gameModePro;

  /// No description provided for @gameDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get gameDifficultyLabel;

  /// No description provided for @gameDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gameDifficultyEasy;

  /// No description provided for @gameDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get gameDifficultyMedium;

  /// No description provided for @gameDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get gameDifficultyHard;

  /// No description provided for @gameDifficultyProTitle.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Selection is Pro'**
  String get gameDifficultyProTitle;

  /// No description provided for @gameDifficultyProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to choose between Medium and Hard difficulty levels.'**
  String get gameDifficultyProMessage;

  /// No description provided for @gameLocalMultiplayerProTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Multiplayer is Pro'**
  String get gameLocalMultiplayerProTitle;

  /// No description provided for @gameLocalMultiplayerProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to play with a friend on the same device, use custom names, and track statistics.'**
  String get gameLocalMultiplayerProMessage;

  /// No description provided for @gameCustomNamesProTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Names is Pro'**
  String get gameCustomNamesProTitle;

  /// No description provided for @gameCustomNamesProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to enter custom player names.'**
  String get gameCustomNamesProMessage;

  /// No description provided for @gamePlayerOneName.
  ///
  /// In en, this message translates to:
  /// **'Player 1 Name'**
  String get gamePlayerOneName;

  /// No description provided for @gamePlayerTwoName.
  ///
  /// In en, this message translates to:
  /// **'Player 2 Name'**
  String get gamePlayerTwoName;

  /// No description provided for @gamePlayerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get gamePlayerNameHint;

  /// No description provided for @gameStartGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get gameStartGame;

  /// No description provided for @gamePlayerTurn.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Turn'**
  String gamePlayerTurn(String name);

  /// No description provided for @gameBotThinking.
  ///
  /// In en, this message translates to:
  /// **'BOT THINKING...'**
  String get gameBotThinking;

  /// No description provided for @gameYouWin.
  ///
  /// In en, this message translates to:
  /// **'{name} Wins!'**
  String gameYouWin(String name);

  /// No description provided for @gameDraw.
  ///
  /// In en, this message translates to:
  /// **'It\'s a Draw!'**
  String get gameDraw;

  /// No description provided for @gamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get gamePlayAgain;

  /// No description provided for @gameBackToSetup.
  ///
  /// In en, this message translates to:
  /// **'Back to Setup'**
  String get gameBackToSetup;

  /// No description provided for @gameStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get gameStatsTitle;

  /// No description provided for @gameStatsProTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics is Pro'**
  String get gameStatsProTitle;

  /// No description provided for @gameStatsProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to track wins per player across sessions.'**
  String get gameStatsProMessage;

  /// No description provided for @gameStatsWins.
  ///
  /// In en, this message translates to:
  /// **'{wins} wins'**
  String gameStatsWins(int wins);

  /// No description provided for @gameStatsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Stats'**
  String get gameStatsClear;

  /// No description provided for @gameStatsClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all statistics for this game?'**
  String get gameStatsClearConfirm;

  /// No description provided for @gameStatsNoData.
  ///
  /// In en, this message translates to:
  /// **'No statistics yet. Play a game to start tracking wins!'**
  String get gameStatsNoData;

  /// No description provided for @gameStatsDraws.
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get gameStatsDraws;

  /// No description provided for @gameTopPlayers.
  ///
  /// In en, this message translates to:
  /// **'Top Players'**
  String get gameTopPlayers;

  /// No description provided for @gameFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: play vs Bot.\nPro: local multiplayer, custom names, difficulty selection & statistics.'**
  String get gameFreeProHint;

  /// No description provided for @gameStatsBot.
  ///
  /// In en, this message translates to:
  /// **'BOT'**
  String get gameStatsBot;

  /// No description provided for @gameStatsPlayer.
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get gameStatsPlayer;

  /// No description provided for @gameInfinityMode.
  ///
  /// In en, this message translates to:
  /// **'Infinity Mode'**
  String get gameInfinityMode;

  /// No description provided for @gameInfinityModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each player keeps at most 3 marks – oldest is removed on the 4th move. No draws!'**
  String get gameInfinityModeSubtitle;
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
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
