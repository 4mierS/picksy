// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Picksy';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPro => 'Pro';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navAnalytics => 'Analytique';

  @override
  String get generatorColor => 'Couleur';

  @override
  String get generatorNumber => 'Nombre';

  @override
  String get generatorCoin => 'Pièce';

  @override
  String get generatorLetter => 'Lettre';

  @override
  String get generatorCustomList => 'Liste personnalisée';

  @override
  String get generatorBottleSpin => 'Bouteille';

  @override
  String get generatorTime => 'Temps';

  @override
  String get generatorReactionTest => 'Test de réaction';

  @override
  String get generatorHangman => 'Pendu';

  @override
  String get commonGenerate => 'Générer';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonCopied => 'Copié';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClear => 'Effacer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonProFeature => 'Fonction Pro';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSystem => 'Système';

  @override
  String get settingsLight => 'Clair';

  @override
  String get settingsDark => 'Sombre';

  @override
  String get settingsReportBug => 'Signaler un bug';

  @override
  String get settingsSuggestFeature => 'Suggérer une fonctionnalité';

  @override
  String get settingsSupportPicksy => 'Soutenir Picksy';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsImprint => 'Imprint';

  @override
  String get settingsTermsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsRequiresGithub => 'Nécessite un compte GitHub';

  @override
  String get settingsProActive => 'Pro actif';

  @override
  String get settingsFreeVersion => 'Version gratuite';

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
  String get settingsRateApp => 'Noter l\'app';

  @override
  String get settingsShareApp => 'Partager l\'app';

  @override
  String get settingsShareAppSubtitle => 'Invitez des amis à essayer Picksy';

  @override
  String get settingsCompareFreePro => 'Comparer Gratuit vs Pro';

  @override
  String get compareTitle => 'Gratuit vs Pro';

  @override
  String get compareFeatureLabel => 'Fonctionnalité';

  @override
  String get compareFreeColumn => 'Gratuit';

  @override
  String get compareProColumn => 'Pro';

  @override
  String get compareFeatureHistory => 'Historique';

  @override
  String get compareFreeHistory => '3 résultats';

  @override
  String get compareProHistory => '1000 résultats';

  @override
  String get compareFeatureFavorites => 'Favoris';

  @override
  String get compareFreeFavorites => 'Jusqu\'à 2';

  @override
  String get compareProFavorites => 'Jusqu\'à 999';

  @override
  String get compareFeatureCoinLabels => 'Libellés pièce';

  @override
  String get compareFeatureColorModes => 'Fonctions couleur';

  @override
  String get compareFeatureCustomRange => 'Fonctions nombre';

  @override
  String get compareFeatureCustomListExtras => 'Liste personnalisée';

  @override
  String get compareFeatureTimeRange => 'Plage de temps';

  @override
  String get compareFeatureLetterFilters => 'Filtres de lettres';

  @override
  String get compareFeatureBottleHaptics => 'Contrôles bouteille';

  @override
  String get compareFeatureAnalytics => 'Analytique';

  @override
  String get proPromoCode => 'Code promo';

  @override
  String get proPromoCodeHint => 'Saisissez le code';

  @override
  String get proPromoCodeApply => 'Appliquer';

  @override
  String get proPromoCodeSuccess => 'Code appliqué ! Pro est maintenant actif.';

  @override
  String get proPromoCodeInvalid => 'Code invalide. Veuillez réessayer.';

  @override
  String get homeSmartRandomDecisions => 'Décisions aléatoires intelligentes';

  @override
  String get homeHistoryTooltip => 'Historique';

  @override
  String get homeFavorites => 'Favoris';

  @override
  String get homeAllGenerators => 'Tous les générateurs';

  @override
  String get homeFavorite => 'Favori';

  @override
  String get homeUnfavorite => 'Retirer des favoris';

  @override
  String get homeTapToOpen => 'Appuyez pour ouvrir';

  @override
  String get homeFavoritesLimitReachedTitle => 'Favorites limit reached';

  @override
  String get homeFavoritesLimitReachedMessage =>
      'Free users can pin up to 2 generators. Go Pro for unlimited favorites.';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyClearAll => 'Tout effacer';

  @override
  String get historyEmpty => 'Pas encore d\'historique';

  @override
  String historyItemSubtitle(Object generator, Object timestamp) {
    return '$generator • $timestamp';
  }

  @override
  String routerComingNext(Object generator) {
    return 'Ensuite : $generator';
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
  String get timeTitle => 'Temps aléatoire';

  @override
  String get timeReady => 'Prêt ?';

  @override
  String get timeReset => 'Réinitialiser';

  @override
  String get timeAgain => 'Encore';

  @override
  String get timeStart => 'Démarrer';

  @override
  String get timeProCustomRangeHint =>
      'Pro : choisissez une plage personnalisée.';

  @override
  String timeFreeCustomRangeHint(int minSec, int maxSec) {
    return 'Gratuit : plage fixe de $minSec à $maxSec secondes. Passez Pro pour des plages personnalisées.';
  }

  @override
  String get timeHideTime => 'Masquer le temps';

  @override
  String get timeHideTimeSubtitle =>
      'Révéler le temps uniquement à la fin (Hot Potato).';

  @override
  String get timeVibrateOnFinish => 'Vibrer à la fin';

  @override
  String get timeRangeSeconds => 'Plage (secondes)';

  @override
  String timeFreeFixedRange(int minSec, int maxSec) {
    return 'Gratuit : fixe $minSec–${maxSec}s';
  }

  @override
  String timeCurrentRange(int min, int max) {
    return 'Actuel : $min - $max s';
  }

  @override
  String get timeRunning => 'En cours…';

  @override
  String get timeHidden => 'Masqué';

  @override
  String timeFormatted(int seconds, Object milliseconds) {
    return '${seconds}s ${milliseconds}ms';
  }

  @override
  String get hangmanTitle => 'Pendu';

  @override
  String get hangmanNewGame => 'Nouvelle partie';

  @override
  String get hangmanPlayAgain => 'Rejouer';

  @override
  String get hangmanYouWon => 'Vous avez gagné !';

  @override
  String hangmanYouLost(Object word) {
    return 'Perdu ! Le mot était : $word';
  }

  @override
  String get hangmanGuessWord => 'Devinez le mot';

  @override
  String hangmanAttemptsLeft(int count) {
    return 'Tentatives restantes : $count';
  }

  @override
  String get hangmanWrongLetters => 'Lettres incorrectes :';

  @override
  String get hangmanSettings => 'Paramètres';

  @override
  String get hangmanMinLength => 'Longueur minimale';

  @override
  String get hangmanMaxLength => 'Longueur maximale';

  @override
  String get analyticsTitle => 'Analytique';

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
    return '$generator Analytique';
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
  String get analyticsBestAccuracy => 'Meilleure précision';

  @override
  String get analyticsAvgAccuracy => 'Précision moyenne';

  @override
  String get generatorColorReflex => 'Réflexe Couleur';

  @override
  String get colorReflexInstructions =>
      'Touchez la couleur du TEXTE, pas du mot !';

  @override
  String get colorReflexDescription =>
      'Utilise l\'Effet Stroop pour tester vos réflexes.';

  @override
  String get colorReflexDurationLabel => 'Durée';

  @override
  String get colorReflexGetReady => 'Préparez-vous !';

  @override
  String get colorReflexTapPrompt => 'Touchez la COULEUR du texte ci-dessus';

  @override
  String get colorReflexTimeUp => 'Temps écoulé !';

  @override
  String get colorReflexCorrectLabel => 'Correct';

  @override
  String get colorReflexWrongLabel => 'Incorrect';

  @override
  String get colorReflexAccuracyLabel => 'Précision';

  @override
  String get colorReflexAvgReactionLabel => 'Réaction moy.';

  @override
  String get colorReflexPlayAgain => 'Rejouer';

  @override
  String get colorReflexBackToMenu => 'Retour au menu';

  @override
  String get colorReflexDurationProTitle => 'La durée personnalisée est Pro';

  @override
  String get colorReflexDurationProMessage =>
      'Passez Pro pour choisir entre 15s, 30s et 60s.';

  @override
  String get colorReflexFreeProHint =>
      'Gratuit : 30 secondes fixes.\nPro : choisissez 15s, 30s ou 60s.';
}
