// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Picksy';

  @override
  String get navHome => 'Home';

  @override
  String get navPro => 'Pro';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get generatorColor => 'Color';

  @override
  String get generatorNumber => 'Number';

  @override
  String get generatorCoin => 'Coin';

  @override
  String get generatorLetter => 'Letter';

  @override
  String get generatorCustomList => 'Custom List';

  @override
  String get generatorBottleSpin => 'Bottle Spin';

  @override
  String get generatorTime => 'Time';

  @override
  String get generatorReactionTest => 'Reaction Test';

  @override
  String get generatorHangman => 'Hangman';

  @override
  String get generatorCard => 'Card Draw';

  @override
  String get cardTitle => 'Card Draw';

  @override
  String get cardTapDraw => 'Tap "Draw" to draw a card';

  @override
  String get cardDraw => 'Draw';

  @override
  String get cardSectionOptions => 'Options';

  @override
  String get cardIncludeJokers => 'Include Jokers';

  @override
  String get cardIncludeJokersSubtitle => 'Add two Jokers to the deck';

  @override
  String get cardIncludeJokersProTitle => 'Jokers are Pro';

  @override
  String get cardIncludeJokersProMessage => 'Go Pro to add Jokers to the deck.';

  @override
  String get cardMultiDrawCount => 'Cards per draw';

  @override
  String get cardMultiDrawProTitle => 'Multi-draw is Pro';

  @override
  String get cardMultiDrawProMessage =>
      'Go Pro to draw multiple cards at once.';

  @override
  String get cardFreeProHint => 'Free: Single draw.\nPro: Jokers + multi-draw.';

  @override
  String get generatorTapChallenge => 'Tap Challenge';

  @override
  String get commonGenerate => 'Generate';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonProFeature => 'Pro feature';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsReportBug => 'Report Bug';

  @override
  String get settingsSuggestFeature => 'Suggest Feature';

  @override
  String get settingsSupportPicksy => 'Buy me a coffee';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsImprint => 'Imprint';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsRequiresGithub => 'Requires a GitHub account';

  @override
  String get settingsProActive => 'Pro active';

  @override
  String get settingsFreeVersion => 'Free version';

  @override
  String get settingsLangEnglish => 'English';

  @override
  String get settingsLangGerman => 'Deutsch';

  @override
  String get settingsLangSpanish => 'Español';

  @override
  String get settingsLangFrench => 'Français';

  @override
  String get settingsLangItalian => 'Italiano';

  @override
  String get settingsRateApp => 'Rate App';

  @override
  String get settingsShareApp => 'Share App';

  @override
  String get settingsShareAppSubtitle => 'Invite friends to try Picksy';

  @override
  String get settingsCompareFreePro => 'Compare Free vs Pro';

  @override
  String get compareTitle => 'Free vs Pro';

  @override
  String get compareFeatureLabel => 'Feature';

  @override
  String get compareFreeColumn => 'Free';

  @override
  String get compareProColumn => 'Pro';

  @override
  String get compareFeatureHistory => 'History';

  @override
  String get compareFreeHistory => '3 results';

  @override
  String get compareProHistory => '1000 results';

  @override
  String get compareFeatureFavorites => 'Favorites';

  @override
  String get compareFreeFavorites => 'Up to 2';

  @override
  String get compareProFavorites => 'Up to 999';

  @override
  String get compareFeatureCoinLabels => 'Coin Labels';

  @override
  String get compareFeatureColorModes => 'Color Features';

  @override
  String get compareFeatureCustomRange => 'Number Features';

  @override
  String get compareFeatureCustomListExtras => 'Custom List';

  @override
  String get compareFeatureTimeRange => 'Timer Range';

  @override
  String get compareFeatureLetterFilters => 'Letter Filters';

  @override
  String get compareFeatureBottleHaptics => 'Bottle Spin Controls';

  @override
  String get compareFeatureAnalytics => 'Analytics';

  @override
  String get proPromoCode => 'Promo Code';

  @override
  String get proPromoCodeHint => 'Enter promo code';

  @override
  String get proPromoCodeApply => 'Apply';

  @override
  String get proPromoCodeSuccess => 'Promo code applied! Pro is now active.';

  @override
  String get proPromoCodeInvalid => 'Invalid promo code. Please try again.';

  @override
  String get homeSmartRandomDecisions => 'Smart random decisions';

  @override
  String get homeHistoryTooltip => 'History';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get homeAllGenerators => 'All Generators';

  @override
  String get homeFavorite => 'Favorite';

  @override
  String get homeUnfavorite => 'Unfavorite';

  @override
  String get homeTapToOpen => 'Tap to open';

  @override
  String get homeFavoritesLimitReachedTitle => 'Favorites limit reached';

  @override
  String get homeFavoritesLimitReachedMessage =>
      'Free users can pin up to 2 generators. Go Pro for unlimited favorites.';

  @override
  String get historyTitle => 'History';

  @override
  String get historyClearAll => 'Clear all';

  @override
  String get historyEmpty => 'No history yet';

  @override
  String historyItemSubtitle(Object generator, Object timestamp) {
    return '$generator • $timestamp';
  }

  @override
  String routerComingNext(Object generator) {
    return 'Coming next: $generator';
  }

  @override
  String get gateNotNow => 'Not now';

  @override
  String get gateGoPro => 'Go Pro';

  @override
  String get gateOpenProTab => 'Open Pro tab to upgrade';

  @override
  String get proGoPro => 'Go Pro';

  @override
  String get proActiveBadge => 'PRO ACTIVE';

  @override
  String get proBadge => 'PRO';

  @override
  String get proThanksActive => 'Thanks! Pro is active on this device.';

  @override
  String get proUnlockDescription =>
      'Unlock Pro features: more history, unlimited favorites, and advanced generators.';

  @override
  String get proIapUnavailable =>
      'In-app purchases are not available on this device/platform.\nTip: IAP works on Android/iOS when installed via the store test track.';

  @override
  String get proWhatYouGet => 'What you get with Pro';

  @override
  String get proFeatureHistory => 'History: 1000 results (Free: 3)';

  @override
  String get proFeatureFavorites => 'Unlimited favorites (Free: 2)';

  @override
  String get proFeatureNumber => 'Number: custom min/max + float + even/odd';

  @override
  String get proFeatureColor => 'Color: palette + modes + contrast';

  @override
  String get proFeatureLetter =>
      'Letter: lowercase + umlauts + vowels + exclude';

  @override
  String get proFeatureCustomList => 'Custom List: undo + weighted (V1)';

  @override
  String get proFeatureBottleSpin => 'Bottle Spin: strength + haptics';

  @override
  String get proChoosePlan => 'Choose your plan';

  @override
  String get proMonthlyTitle => 'Pro Monthly';

  @override
  String get proMonthlySubtitle => 'Best if you want to try it out';

  @override
  String get proLifetimeTitle => 'Lifetime Unlock';

  @override
  String get proLifetimeSubtitle => 'Pay once, keep Pro forever';

  @override
  String get proPopular => 'POPULAR';

  @override
  String get proUnlockButton => 'Unlock';

  @override
  String get proActiveButton => 'Active';

  @override
  String get proRestorePurchases => 'Restore purchases';

  @override
  String get proPrivacyNote =>
      'Privacy: No account required. All data stays on your device.';

  @override
  String get proPaymentsNote =>
      'Payments and restore are handled via your Apple/Google store account.';

  @override
  String get proMonthlyFallbackPrice => '€0.49 / month';

  @override
  String get proLifetimeFallbackPrice => '€7.49 one-time';

  @override
  String get coinTitle => 'Coin';

  @override
  String get coinTapFlip => 'Tap \"Flip\" to get a result';

  @override
  String get coinFlip => 'Flip';

  @override
  String get coinSectionLabels => 'Labels';

  @override
  String get coinOptionA => 'Option A';

  @override
  String get coinOptionB => 'Option B';

  @override
  String get coinHintA => 'Heads / Yes / True...';

  @override
  String get coinHintB => 'Tails / No / False...';

  @override
  String get coinCustomLabelsProTitle => 'Custom labels are Pro';

  @override
  String get coinCustomLabelsProMessage =>
      'Go Pro to define your own labels (e.g. Yes/No, True/False).';

  @override
  String get coinFreeProHint => 'Free: Heads/Tails.\nPro: Custom labels.';

  @override
  String get coinDefaultHeads => 'Heads';

  @override
  String get coinDefaultTails => 'Tails';

  @override
  String get colorTitle => 'Color';

  @override
  String get colorSectionMode => 'Mode';

  @override
  String get colorSectionPalette => 'Palette';

  @override
  String get colorGeneratePalette => 'Generate Palette (5)';

  @override
  String get colorCopiedHex => 'Copied HEX';

  @override
  String get colorModesProTitle => 'Color Modes are Pro';

  @override
  String get colorModesProMessage =>
      'Go Pro to unlock Pastel, Neon and Dark modes.';

  @override
  String get colorModesUpgradeMessage =>
      'Upgrade to use different color styles.';

  @override
  String get colorPaletteProTitle => 'Palette is Pro';

  @override
  String get colorPaletteProMessage =>
      'Generate harmonious color palettes with Pro.';

  @override
  String get colorModeNormal => 'Normal';

  @override
  String get colorModePastel => 'Pastel';

  @override
  String get colorModeNeon => 'Neon';

  @override
  String get colorModeDark => 'Dark';

  @override
  String get colorFreeProHint =>
      'Free: Random HEX color.\nPro: Color modes, palette, contrast detection.';

  @override
  String get letterTitle => 'Letter';

  @override
  String get letterTapGenerate => 'Tap \"Generate\" to get a letter';

  @override
  String get letterSectionFilters => 'Filters';

  @override
  String get letterUppercase => 'Uppercase';

  @override
  String get letterUppercaseSubtitle => 'Include A-Z';

  @override
  String get letterLowercase => 'Lowercase';

  @override
  String get letterLowercaseSubtitle => 'Include a-z';

  @override
  String get letterIncludeUmlauts => 'Include umlauts';

  @override
  String get letterIncludeUmlautsSubtitle =>
      'Add ä, ö, ü (and Ä, Ö, Ü if uppercase enabled)';

  @override
  String get letterOnlyVowels => 'Only vowels';

  @override
  String get letterOnlyVowelsSubtitle =>
      'Limit selection to vowels (A E I O U + optional umlauts)';

  @override
  String get letterExcludeLetters => 'Exclude letters';

  @override
  String get letterExcludeNone => 'None';

  @override
  String get letterFiltersProTitle => 'Letter filters are Pro';

  @override
  String get letterFiltersProMessage =>
      'Go Pro to unlock lowercase, umlauts, vowels-only, and exclusions.';

  @override
  String get letterFreeProHint =>
      'Free: Random A-Z uppercase.\nPro: lowercase, umlauts, vowels-only, exclude letters.';

  @override
  String get numberTitle => 'Number';

  @override
  String get numberTapGenerate => 'Tap \"Generate\" to get a number';

  @override
  String get numberSectionRange => 'Range';

  @override
  String get numberSectionType => 'Type';

  @override
  String get numberSectionFilter => 'Filter';

  @override
  String get numberInvalidRange => 'Max must be >= Min';

  @override
  String get numberFloat => 'Float (decimals)';

  @override
  String get numberFloatSubtitle => 'Generate decimal numbers';

  @override
  String get numberCustomRangeProTitle => 'Custom range is Pro';

  @override
  String get numberCustomRangeProMessage =>
      'Free users can generate numbers from 0 to 100. Go Pro to set your own min/max.';

  @override
  String get numberFloatProTitle => 'Float mode is Pro';

  @override
  String get numberFloatProMessage => 'Go Pro to generate decimal numbers.';

  @override
  String get numberParityProTitle => 'Even/Odd filter is Pro';

  @override
  String get numberParityProMessage =>
      'Go Pro to filter for even or odd numbers.';

  @override
  String get numberParityAny => 'Any';

  @override
  String get numberParityEven => 'Even';

  @override
  String get numberParityOdd => 'Odd';

  @override
  String get numberMin => 'Min';

  @override
  String get numberMax => 'Max';

  @override
  String get numberFreeProHint =>
      'Free limits: range 0-100, integer only.\nGo Pro for custom range, floats, and even/odd filters.';

  @override
  String get customListTitle => 'Custom List';

  @override
  String get customListNewList => 'New list';

  @override
  String get customListSelectList => 'Select list';

  @override
  String get customListDeleteList => 'Delete list';

  @override
  String get customListListName => 'List name';

  @override
  String get customListWithReplacement => 'With replacement';

  @override
  String get customListWithReplacementOn => 'Picked item stays in the list';

  @override
  String get customListWithReplacementOff =>
      'Picked item is removed (auto resets when empty)';

  @override
  String get customListTeamMode => 'Team mode';

  @override
  String get customListTeamModeOn => 'Generate teams from all list items';

  @override
  String get customListTeamModeOff => 'Pick one random item';

  @override
  String get customListTeamsLabel => 'Teams:';

  @override
  String customListPeopleCount(int count) {
    return '$count people';
  }

  @override
  String get customListTeamsCardTitle => 'Teams';

  @override
  String customListTeamTitle(int index) {
    return 'Team $index';
  }

  @override
  String customListTeamHistoryLine(int index, Object members) {
    return 'Team $index: $members';
  }

  @override
  String get customListEmptyTeam => '(empty)';

  @override
  String get customListNoItems => '(no items)';

  @override
  String customListPicked(Object value) {
    return 'Picked: $value';
  }

  @override
  String get customListGenerateTeams => 'Generate Teams';

  @override
  String get customListPickRandom => 'Pick Random';

  @override
  String get customListRestoreRemoved => 'Restore removed';

  @override
  String get customListResetAll => 'Reset all';

  @override
  String get customListResetAllTitle => 'Reset all items?';

  @override
  String get customListResetAllMessage =>
      'This will remove all items from the list. This cannot be undone.';

  @override
  String get customListResetAllConfirm => 'Yes, reset';

  @override
  String get customListAddItem => 'Add item';

  @override
  String get customListAddItemHint => 'e.g. Pizza';

  @override
  String get customListNoListSelected => 'No list selected';

  @override
  String get bottleSpinTitle => 'Bottle Spin';

  @override
  String get bottleSpinInstructions =>
      'Place your phone on the table. Tap Spin. The bottle points to someone in the circle.';

  @override
  String get bottleSpinSpinning => 'Spinning...';

  @override
  String get bottleSpinSpin => 'Spin';

  @override
  String get bottleSpinSectionControls => 'Controls';

  @override
  String get bottleSpinStrength => 'Spin strength';

  @override
  String get bottleSpinStrengthSubtitle => 'More strength = more rotations';

  @override
  String get bottleSpinStrengthProTitle => 'Spin strength is Pro';

  @override
  String get bottleSpinStrengthProMessage =>
      'Go Pro to adjust how strong the bottle spins.';

  @override
  String get bottleSpinHaptic => 'Haptic feedback';

  @override
  String get bottleSpinHapticSubtitle => 'Vibrate when the bottle stops';

  @override
  String get bottleSpinHapticProTitle => 'Haptics are Pro';

  @override
  String get bottleSpinHapticProMessage =>
      'Go Pro to enable vibration feedback.';

  @override
  String get bottleSpinHapticEnabled => 'Haptics enabled for this session';

  @override
  String get bottleSpinFreeProHint =>
      'Free: Spin bottle.\nPro: Adjust spin strength + haptic feedback.';

  @override
  String bottleSpinAngleValue(Object degree) {
    return 'Angle: $degree°';
  }

  @override
  String get timeTitle => 'Random Time';

  @override
  String get timeReady => 'Ready?';

  @override
  String get timeReset => 'Reset';

  @override
  String get timeAgain => 'Again';

  @override
  String get timeStart => 'Start';

  @override
  String get timeProCustomRangeHint => 'Pro: choose a custom range.';

  @override
  String timeFreeCustomRangeHint(int minSec, int maxSec) {
    return 'Free: fixed range $minSec–$maxSec seconds. Upgrade for custom ranges.';
  }

  @override
  String get timeHideTime => 'Hide time';

  @override
  String get timeHideTimeSubtitle =>
      'Reveal the time only when it ends (Hot Potato).';

  @override
  String get timeVibrateOnFinish => 'Vibrate on finish';

  @override
  String get timeRangeSeconds => 'Range (seconds)';

  @override
  String timeFreeFixedRange(int minSec, int maxSec) {
    return 'Free: fixed $minSec–${maxSec}s';
  }

  @override
  String timeCurrentRange(int min, int max) {
    return 'Current: $min - $max s';
  }

  @override
  String get timeRunning => 'Running…';

  @override
  String get timeHidden => 'Hidden';

  @override
  String timeFormatted(int seconds, Object milliseconds) {
    return '${seconds}s ${milliseconds}ms';
  }

  @override
  String get hangmanTitle => 'Hangman';

  @override
  String get hangmanNewGame => 'New Game';

  @override
  String get hangmanPlayAgain => 'Play Again';

  @override
  String get hangmanYouWon => 'You won!';

  @override
  String hangmanYouLost(Object word) {
    return 'Game over! The word was: $word';
  }

  @override
  String get hangmanGuessWord => 'Guess the word';

  @override
  String hangmanAttemptsLeft(int count) {
    return 'Attempts left: $count';
  }

  @override
  String get hangmanWrongLetters => 'Wrong letters:';

  @override
  String get hangmanSettings => 'Settings';

  @override
  String get hangmanMinLength => 'Min word length';

  @override
  String get hangmanMaxLength => 'Max word length';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsProOnly => 'Analytics is a Pro feature';

  @override
  String get analyticsProMessage =>
      'Unlock advanced analytics, trends and auto-run with Picksy Pro.';

  @override
  String get analyticsEmpty => 'No data yet. Generate some results first.';

  @override
  String get analyticsViewAll => 'View All';

  @override
  String analyticsGeneratorTitle(Object generator) {
    return '$generator Analytics';
  }

  @override
  String get analyticsAutoRun => 'Auto-Run';

  @override
  String get analyticsAutoRunCount => 'Count';

  @override
  String get analyticsAutoRunStart => 'Start';

  @override
  String get analyticsAutoRunRunning => 'Running…';

  @override
  String get analyticsAutoRunResults => 'Results';

  @override
  String get analyticsAutoRunDistribution => 'Distribution';

  @override
  String get analyticsBestTime => 'Best time';

  @override
  String get analyticsAvgTime => 'Avg time';

  @override
  String get analyticsTotal => 'Total';

  @override
  String get analyticsWins => 'Wins';

  @override
  String get analyticsLosses => 'Losses';

  @override
  String get analyticsWinRate => 'Win rate';

  @override
  String get analyticsHighScore => 'High score';

  @override
  String get analyticsFrequency => 'Frequency';

  @override
  String get analyticsBestAccuracy => 'Best accuracy';

  @override
  String get analyticsAvgAccuracy => 'Avg accuracy';

  @override
  String get generatorColorReflex => 'Color Reflex';

  @override
  String get colorReflexInstructions =>
      'Tap the color of the TEXT, not the word!';

  @override
  String get colorReflexDescription =>
      'Uses the Stroop Effect to test your reflexes.';

  @override
  String get colorReflexDurationLabel => 'Duration';

  @override
  String get colorReflexGetReady => 'Get ready!';

  @override
  String get colorReflexTapPrompt => 'Tap the COLOR of the text above';

  @override
  String get colorReflexTimeUp => 'Time\'s up!';

  @override
  String get colorReflexCorrectLabel => 'Correct';

  @override
  String get colorReflexWrongLabel => 'Wrong';

  @override
  String get colorReflexAccuracyLabel => 'Accuracy';

  @override
  String get colorReflexAvgReactionLabel => 'Avg reaction';

  @override
  String get colorReflexPlayAgain => 'Play Again';

  @override
  String get colorReflexBackToMenu => 'Back to menu';

  @override
  String get colorReflexDurationProTitle => 'Custom duration is Pro';

  @override
  String get colorReflexDurationProMessage =>
      'Go Pro to choose between 15s, 30s, and 60s durations.';

  @override
  String get colorReflexFreeProHint =>
      'Free: 30 seconds fixed.\nPro: choose 15s, 30s, or 60s.';

  @override
  String get tapChallengeTitle => 'Tap Challenge';

  @override
  String get tapChallengeInstructions =>
      'Tap as fast as you can when GO appears!';

  @override
  String get tapChallengeStart => 'Start';

  @override
  String get tapChallengeAgain => 'Try Again';

  @override
  String get tapChallengeTaps => 'Taps';

  @override
  String get tapChallengeTPS => 'Taps/sec';

  @override
  String get tapChallengePersonalBest => 'Personal Best';

  @override
  String get tapChallengeDurationLabel => 'Duration';

  @override
  String tapChallengeDurationSeconds(int seconds) => '${seconds}s';

  @override
  String get tapChallengeDurationProTitle => 'Custom Duration is Pro';

  @override
  String get tapChallengeDurationProMessage =>
      'Go Pro to set the challenge duration to 5s, 10s, 15s, 30s, or 60s.';

  @override
  String get tapChallengeVibrateOnGo => 'Vibrate on GO';

  @override
  String get tapChallengeVibrateOnEnd => 'Vibrate on end';

  @override
  String get tapChallengeFreeProHint =>
      'Free: 5-second run.\nPro: choose duration (5s, 10s, 15s, 30s, 60s) + advanced analytics.';

  @override
  String get tapChallengeGo => 'GO!';

  @override
  String get tapChallengeGetReady => 'Get Ready';

  @override
  String get tapChallengeResultTitle => 'Run Complete!';

  @override
  String get tapChallengeAnalyticsPersonalBest => 'Best Taps';

  @override
  String get tapChallengeAnalyticsAvgTaps => 'Avg Taps';

  @override
  String get tapChallengeAnalyticsAvgTPS => 'Avg TPS';

  @override
  String get tapChallengeAnalyticsBestTPS => 'Best TPS';
}
