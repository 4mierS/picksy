// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Picksy';

  @override
  String get navHome => 'Home';

  @override
  String get navPro => 'Pro';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navAnalytics => 'Analisi';

  @override
  String get generatorColor => 'Colore';

  @override
  String get generatorNumber => 'Numero';

  @override
  String get generatorCoin => 'Moneta';

  @override
  String get generatorLetter => 'Lettera';

  @override
  String get generatorCustomList => 'Lista personalizzata';

  @override
  String get generatorBottleSpin => 'Bottiglia';

  @override
  String get generatorTime => 'Tempo';

  @override
  String get generatorReactionTest => 'Test di reazione';

  @override
  String get generatorHangman => 'Impiccato';

  @override
  String get commonGenerate => 'Genera';

  @override
  String get commonCopy => 'Copia';

  @override
  String get commonCopied => 'Copiato';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonClear => 'Cancella';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonAdd => 'Aggiungi';

  @override
  String get commonProFeature => 'Funzione Pro';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsLight => 'Chiaro';

  @override
  String get settingsDark => 'Scuro';

  @override
  String get settingsReportBug => 'Segnala bug';

  @override
  String get settingsSuggestFeature => 'Suggerisci funzione';

  @override
  String get settingsSupportPicksy => 'Supporta Picksy';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsImprint => 'Imprint';

  @override
  String get settingsTermsOfService => 'Termini di servizio';

  @override
  String get settingsRequiresGithub => 'Richiede un account GitHub';

  @override
  String get settingsProActive => 'Pro attivo';

  @override
  String get settingsFreeVersion => 'Versione gratuita';

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
  String get settingsRateApp => 'Valuta l\'app';

  @override
  String get settingsShareApp => 'Condividi app';

  @override
  String get settingsShareAppSubtitle => 'Invita amici a provare Picksy';

  @override
  String get settingsCompareFreePro => 'Confronta Gratis vs Pro';

  @override
  String get compareTitle => 'Gratis vs Pro';

  @override
  String get compareFeatureLabel => 'Funzione';

  @override
  String get compareFreeColumn => 'Gratis';

  @override
  String get compareProColumn => 'Pro';

  @override
  String get compareFeatureHistory => 'Cronologia';

  @override
  String get compareFreeHistory => '3 risultati';

  @override
  String get compareProHistory => '1000 risultati';

  @override
  String get compareFeatureFavorites => 'Preferiti';

  @override
  String get compareFreeFavorites => 'Fino a 2';

  @override
  String get compareProFavorites => 'Fino a 999';

  @override
  String get compareFeatureCoinLabels => 'Etichette moneta';

  @override
  String get compareFeatureColorModes => 'Funzioni colore';

  @override
  String get compareFeatureCustomRange => 'Funzioni numero';

  @override
  String get compareFeatureCustomListExtras => 'Lista personalizzata';

  @override
  String get compareFeatureTimeRange => 'Intervallo timer';

  @override
  String get compareFeatureLetterFilters => 'Filtri lettere';

  @override
  String get compareFeatureBottleHaptics => 'Controlli bottiglia';

  @override
  String get compareFeatureAnalytics => 'Analisi';

  @override
  String get proPromoCode => 'Codice promo';

  @override
  String get proPromoCodeHint => 'Inserisci il codice';

  @override
  String get proPromoCodeApply => 'Applica';

  @override
  String get proPromoCodeSuccess => 'Codice applicato! Pro è ora attivo.';

  @override
  String get proPromoCodeInvalid => 'Codice non valido. Riprova.';

  @override
  String get homeSmartRandomDecisions => 'Decisioni casuali intelligenti';

  @override
  String get homeHistoryTooltip => 'Cronologia';

  @override
  String get homeFavorites => 'Preferiti';

  @override
  String get homeAllGenerators => 'Tutti i generatori';

  @override
  String get homeFavorite => 'Preferito';

  @override
  String get homeUnfavorite => 'Rimuovi dai preferiti';

  @override
  String get homeTapToOpen => 'Tocca per aprire';

  @override
  String get homeFavoritesLimitReachedTitle => 'Favorites limit reached';

  @override
  String get homeFavoritesLimitReachedMessage =>
      'Free users can pin up to 2 generators. Go Pro for unlimited favorites.';

  @override
  String get historyTitle => 'Cronologia';

  @override
  String get historyClearAll => 'Cancella tutto';

  @override
  String get historyEmpty => 'Nessuna cronologia';

  @override
  String historyItemSubtitle(Object generator, Object timestamp) {
    return '$generator • $timestamp';
  }

  @override
  String routerComingNext(Object generator) {
    return 'Prossimo: $generator';
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
  String get timeTitle => 'Tempo casuale';

  @override
  String get timeReady => 'Pronto?';

  @override
  String get timeReset => 'Reimposta';

  @override
  String get timeAgain => 'Di nuovo';

  @override
  String get timeStart => 'Avvia';

  @override
  String get timeProCustomRangeHint =>
      'Pro: scegli un intervallo personalizzato.';

  @override
  String timeFreeCustomRangeHint(int minSec, int maxSec) {
    return 'Gratis: intervallo fisso $minSec–$maxSec secondi. Passa a Pro per intervalli personalizzati.';
  }

  @override
  String get timeHideTime => 'Nascondi tempo';

  @override
  String get timeHideTimeSubtitle =>
      'Mostra il tempo solo alla fine (Hot Potato).';

  @override
  String get timeVibrateOnFinish => 'Vibra alla fine';

  @override
  String get timeRangeSeconds => 'Intervallo (secondi)';

  @override
  String timeFreeFixedRange(int minSec, int maxSec) {
    return 'Gratis: fisso $minSec–${maxSec}s';
  }

  @override
  String timeCurrentRange(int min, int max) {
    return 'Attuale: $min - $max s';
  }

  @override
  String get timeRunning => 'In esecuzione…';

  @override
  String get timeHidden => 'Nascosto';

  @override
  String timeFormatted(int seconds, Object milliseconds) {
    return '${seconds}s ${milliseconds}ms';
  }

  @override
  String get hangmanTitle => 'Impiccato';

  @override
  String get hangmanNewGame => 'Nuova partita';

  @override
  String get hangmanPlayAgain => 'Gioca di nuovo';

  @override
  String get hangmanYouWon => 'Hai vinto!';

  @override
  String hangmanYouLost(Object word) {
    return 'Hai perso! La parola era: $word';
  }

  @override
  String get hangmanGuessWord => 'Indovina la parola';

  @override
  String hangmanAttemptsLeft(int count) {
    return 'Tentativi rimasti: $count';
  }

  @override
  String get hangmanWrongLetters => 'Lettere errate:';

  @override
  String get hangmanSettings => 'Impostazioni';

  @override
  String get hangmanMinLength => 'Lunghezza minima';

  @override
  String get hangmanMaxLength => 'Lunghezza massima';

  @override
  String get analyticsTitle => 'Analisi';

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
    return '$generator Analisi';
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
}
