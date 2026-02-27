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

  /// No description provided for @commonGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get commonGenerate;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get commonCopied;

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
  /// **'Support Picksy'**
  String get settingsSupportPicksy;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

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
  /// **'History: 50 results (Free: 3)'**
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

  /// No description provided for @proFeatureColor.
  ///
  /// In en, this message translates to:
  /// **'Color: palette + modes + contrast'**
  String get proFeatureColor;

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
  /// **'€7.49 one-time'**
  String get proLifetimeFallbackPrice;

  /// No description provided for @coinTitle.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get coinTitle;

  /// No description provided for @coinTapFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Flip\" to get a result'**
  String get coinTapFlip;

  /// No description provided for @coinFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get coinFlip;

  /// No description provided for @coinSectionLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get coinSectionLabels;

  /// No description provided for @coinOptionA.
  ///
  /// In en, this message translates to:
  /// **'Option A'**
  String get coinOptionA;

  /// No description provided for @coinOptionB.
  ///
  /// In en, this message translates to:
  /// **'Option B'**
  String get coinOptionB;

  /// No description provided for @coinHintA.
  ///
  /// In en, this message translates to:
  /// **'Heads / Yes / True...'**
  String get coinHintA;

  /// No description provided for @coinHintB.
  ///
  /// In en, this message translates to:
  /// **'Tails / No / False...'**
  String get coinHintB;

  /// No description provided for @coinCustomLabelsProTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom labels are Pro'**
  String get coinCustomLabelsProTitle;

  /// No description provided for @coinCustomLabelsProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to define your own labels (e.g. Yes/No, True/False).'**
  String get coinCustomLabelsProMessage;

  /// No description provided for @coinFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: Heads/Tails.\nPro: Custom labels.'**
  String get coinFreeProHint;

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

  /// No description provided for @colorSectionMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get colorSectionMode;

  /// No description provided for @colorSectionPalette.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get colorSectionPalette;

  /// No description provided for @colorGeneratePalette.
  ///
  /// In en, this message translates to:
  /// **'Generate Palette (5)'**
  String get colorGeneratePalette;

  /// No description provided for @colorCopiedHex.
  ///
  /// In en, this message translates to:
  /// **'Copied HEX'**
  String get colorCopiedHex;

  /// No description provided for @colorModesProTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Modes are Pro'**
  String get colorModesProTitle;

  /// No description provided for @colorModesProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to unlock Pastel, Neon and Dark modes.'**
  String get colorModesProMessage;

  /// No description provided for @colorModesUpgradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to use different color styles.'**
  String get colorModesUpgradeMessage;

  /// No description provided for @colorPaletteProTitle.
  ///
  /// In en, this message translates to:
  /// **'Palette is Pro'**
  String get colorPaletteProTitle;

  /// No description provided for @colorPaletteProMessage.
  ///
  /// In en, this message translates to:
  /// **'Generate harmonious color palettes with Pro.'**
  String get colorPaletteProMessage;

  /// No description provided for @colorModeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get colorModeNormal;

  /// No description provided for @colorModePastel.
  ///
  /// In en, this message translates to:
  /// **'Pastel'**
  String get colorModePastel;

  /// No description provided for @colorModeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get colorModeNeon;

  /// No description provided for @colorModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get colorModeDark;

  /// No description provided for @colorFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: Random HEX color.\nPro: Color modes, palette, contrast detection.'**
  String get colorFreeProHint;

  /// No description provided for @letterTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get letterTitle;

  /// No description provided for @letterTapGenerate.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Generate\" to get a letter'**
  String get letterTapGenerate;

  /// No description provided for @letterSectionFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get letterSectionFilters;

  /// No description provided for @letterUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase'**
  String get letterUppercase;

  /// No description provided for @letterUppercaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include A–Z'**
  String get letterUppercaseSubtitle;

  /// No description provided for @letterLowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase'**
  String get letterLowercase;

  /// No description provided for @letterLowercaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include a–z'**
  String get letterLowercaseSubtitle;

  /// No description provided for @letterIncludeUmlauts.
  ///
  /// In en, this message translates to:
  /// **'Include umlauts'**
  String get letterIncludeUmlauts;

  /// No description provided for @letterIncludeUmlautsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add ä, ö, ü (and Ä, Ö, Ü if uppercase enabled)'**
  String get letterIncludeUmlautsSubtitle;

  /// No description provided for @letterOnlyVowels.
  ///
  /// In en, this message translates to:
  /// **'Only vowels'**
  String get letterOnlyVowels;

  /// No description provided for @letterOnlyVowelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Limit selection to vowels (A E I O U + optional umlauts)'**
  String get letterOnlyVowelsSubtitle;

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

  /// No description provided for @letterFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: Random A–Z uppercase.\nPro: lowercase, umlauts, vowels-only, exclude letters.'**
  String get letterFreeProHint;

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
  /// **'Free limits: range 0–100, integer only.\nGo Pro for custom range, floats, and even/odd filters.'**
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

  /// No description provided for @customListListName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get customListListName;

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

  /// No description provided for @customListResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get customListResetAll;

  /// No description provided for @customListResetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all items?'**
  String get customListResetAllTitle;

  /// No description provided for @customListResetAllMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all items from the list. This cannot be undone.'**
  String get customListResetAllMessage;

  /// No description provided for @customListResetAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, reset'**
  String get customListResetAllConfirm;

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

  /// No description provided for @bottleSpinInstructions.
  ///
  /// In en, this message translates to:
  /// **'Place your phone on the table. Tap Spin. The bottle points to someone in the circle.'**
  String get bottleSpinInstructions;

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

  /// No description provided for @bottleSpinSectionControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get bottleSpinSectionControls;

  /// No description provided for @bottleSpinStrength.
  ///
  /// In en, this message translates to:
  /// **'Spin strength'**
  String get bottleSpinStrength;

  /// No description provided for @bottleSpinStrengthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'More strength = more rotations'**
  String get bottleSpinStrengthSubtitle;

  /// No description provided for @bottleSpinStrengthProTitle.
  ///
  /// In en, this message translates to:
  /// **'Spin strength is Pro'**
  String get bottleSpinStrengthProTitle;

  /// No description provided for @bottleSpinStrengthProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to adjust how strong the bottle spins.'**
  String get bottleSpinStrengthProMessage;

  /// No description provided for @bottleSpinHaptic.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get bottleSpinHaptic;

  /// No description provided for @bottleSpinHapticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate when the bottle stops'**
  String get bottleSpinHapticSubtitle;

  /// No description provided for @bottleSpinHapticProTitle.
  ///
  /// In en, this message translates to:
  /// **'Haptics are Pro'**
  String get bottleSpinHapticProTitle;

  /// No description provided for @bottleSpinHapticProMessage.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to enable vibration feedback.'**
  String get bottleSpinHapticProMessage;

  /// No description provided for @bottleSpinHapticEnabled.
  ///
  /// In en, this message translates to:
  /// **'Haptics enabled for this session'**
  String get bottleSpinHapticEnabled;

  /// No description provided for @bottleSpinFreeProHint.
  ///
  /// In en, this message translates to:
  /// **'Free: Spin bottle.\nPro: Adjust spin strength + haptic feedback.'**
  String get bottleSpinFreeProHint;

  /// No description provided for @bottleSpinAngleValue.
  ///
  /// In en, this message translates to:
  /// **'Angle: {degree}°'**
  String bottleSpinAngleValue(Object degree);
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
