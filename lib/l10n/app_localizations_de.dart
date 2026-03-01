// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Picksy';

  @override
  String get navHome => 'Start';

  @override
  String get navPro => 'Pro';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navAnalytics => 'Analytik';

  @override
  String get generatorColor => 'Farbe';

  @override
  String get generatorNumber => 'Zahl';

  @override
  String get generatorCoin => 'Münze';

  @override
  String get generatorLetter => 'Buchstabe';

  @override
  String get generatorCustomList => 'Eigene Liste';

  @override
  String get generatorBottleSpin => 'Flaschendrehen';

  @override
  String get generatorTime => 'Zeit';

  @override
  String get generatorReactionTest => 'Reaktionstest';

  @override
  String get generatorHangman => 'Galgenmännchen';

  @override
  String get generatorMathChallenge => 'Mathe-Challenge';

  @override
  String get commonGenerate => 'Generieren';

  @override
  String get commonCopy => 'Kopieren';

  @override
  String get commonCopied => 'Kopiert';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClear => 'Leeren';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonProFeature => 'Pro-Funktion';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsLight => 'Hell';

  @override
  String get settingsDark => 'Dunkel';

  @override
  String get settingsReportBug => 'Fehler melden';

  @override
  String get settingsSuggestFeature => 'Funktion vorschlagen';

  @override
  String get settingsSupportPicksy => 'Picksy unterstützen';

  @override
  String get settingsPrivacyPolicy => 'Datenschutz';

  @override
  String get settingsImprint => 'Impressum';

  @override
  String get settingsTermsOfService => 'Nutzungsbedingungen';

  @override
  String get settingsRequiresGithub => 'Benötigt ein GitHub-Konto';

  @override
  String get settingsProActive => 'Pro aktiv';

  @override
  String get settingsFreeVersion => 'Kostenlose Version';

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
  String get homeSmartRandomDecisions => 'Smarte Zufallsentscheidungen';

  @override
  String get homeHistoryTooltip => 'Verlauf';

  @override
  String get homeFavorites => 'Favoriten';

  @override
  String get homeAllGenerators => 'Alle Generatoren';

  @override
  String get homeFavorite => 'Favorit';

  @override
  String get homeUnfavorite => 'Nicht mehr Favorit';

  @override
  String get homeTapToOpen => 'Tippen zum Öffnen';

  @override
  String get homeFavoritesLimitReachedTitle => 'Favorites limit reached';

  @override
  String get homeFavoritesLimitReachedMessage =>
      'Free users can pin up to 2 generators. Go Pro for unlimited favorites.';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historyClearAll => 'Alles löschen';

  @override
  String get historyEmpty => 'Noch kein Verlauf';

  @override
  String historyItemSubtitle(Object generator, Object timestamp) {
    return '$generator • $timestamp';
  }

  @override
  String routerComingNext(Object generator) {
    return 'Als nächstes: $generator';
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
  String get proFeatureHistory => 'History: 50 results (Free: 3)';

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
  String get timeTitle => 'Zufallszeit';

  @override
  String get timeReady => 'Bereit?';

  @override
  String get timeReset => 'Zurücksetzen';

  @override
  String get timeAgain => 'Nochmal';

  @override
  String get timeStart => 'Start';

  @override
  String get timeProCustomRangeHint => 'Pro: Wähle einen eigenen Bereich.';

  @override
  String timeFreeCustomRangeHint(int minSec, int maxSec) {
    return 'Free: fester Bereich $minSec–$maxSec Sekunden. Upgrade für eigene Bereiche.';
  }

  @override
  String get timeHideTime => 'Zeit ausblenden';

  @override
  String get timeHideTimeSubtitle =>
      'Zeige die Zeit erst am Ende an (Hot Potato).';

  @override
  String get timeVibrateOnFinish => 'Bei Ende vibrieren';

  @override
  String get timeRangeSeconds => 'Bereich (Sekunden)';

  @override
  String timeFreeFixedRange(int minSec, int maxSec) {
    return 'Free: fest $minSec–${maxSec}s';
  }

  @override
  String timeCurrentRange(int min, int max) {
    return 'Aktuell: $min - $max s';
  }

  @override
  String get timeRunning => 'Läuft…';

  @override
  String get timeHidden => 'Versteckt';

  @override
  String timeFormatted(int seconds, Object milliseconds) {
    return '${seconds}s ${milliseconds}ms';
  }

  @override
  String get hangmanTitle => 'Galgenmännchen';

  @override
  String get hangmanNewGame => 'Neues Spiel';

  @override
  String get hangmanPlayAgain => 'Nochmal spielen';

  @override
  String get hangmanYouWon => 'Gewonnen!';

  @override
  String hangmanYouLost(Object word) {
    return 'Verloren! Das Wort war: $word';
  }

  @override
  String get hangmanGuessWord => 'Rate das Wort';

  @override
  String hangmanAttemptsLeft(int count) {
    return 'Versuche übrig: $count';
  }

  @override
  String get hangmanWrongLetters => 'Falsche Buchstaben:';

  @override
  String get hangmanSettings => 'Einstellungen';

  @override
  String get hangmanMinLength => 'Minimale Wortlänge';

  @override
  String get hangmanMaxLength => 'Maximale Wortlänge';

  @override
  String get analyticsTitle => 'Analytik';

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
    return '$generator Analytik';
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
  String get mathChallengeTitle => 'Mathe-Challenge';

  @override
  String get mathDifficulty => 'Schwierigkeit';

  @override
  String get mathDifficultyEasy => 'Einfach';

  @override
  String get mathDifficultyHard => 'Schwer';

  @override
  String get mathDifficultyProTitle => 'Schwerer Modus ist Pro';

  @override
  String get mathDifficultyProMessage => 'Werde Pro, um Multiplikation, Division und größere Zahlen freizuschalten.';

  @override
  String get mathDuration => 'Dauer';

  @override
  String mathDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get mathDurationFree => 'Fest: 30 Sekunden';

  @override
  String get mathDurationProTitle => 'Benutzerdefinierte Dauer ist Pro';

  @override
  String get mathDurationProMessage => 'Werde Pro, um eine Dauer von 15 bis 60 Sekunden zu wählen.';

  @override
  String get mathStart => 'Start';

  @override
  String get mathTimeLeft => 'Zeit';

  @override
  String get mathCorrect => 'Richtig';

  @override
  String get mathWrong => 'Falsch';

  @override
  String get mathResultTitle => 'Ergebnis';

  @override
  String get mathAccuracy => 'Genauigkeit';

  @override
  String get mathPPS => 'Pro Sek.';

  @override
  String get mathPlayAgain => 'Nochmal spielen';

  @override
  String get mathBackToMenu => 'Zurück zum Menü';

  @override
  String get mathFreeProHint => 'Free: Addition & Subtraktion, 30 Sekunden.\nPro: alle Operationen, benutzerdefinierte Dauer.';

  @override
  String get mathAvgAccuracy => 'Durchschn. Genauigkeit';
}
