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
  String get generatorMemoryFlash => 'Memory Flash';

  @override
  String get generatorTapChallenge => 'Sfida di tocchi';

  @override
  String get generatorMathChallenge => 'Sfida matematica';

  @override
  String get commonGenerate => 'Genera';

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
  String get coinFlip => 'Flip';

  @override
  String get coinDefaultHeads => 'Heads';

  @override
  String get coinDefaultTails => 'Tails';

  @override
  String get colorTitle => 'Color';

  @override
  String get letterTitle => 'Letter';

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

  @override
  String get analyticsAvgLevel => 'Livello medio';

  @override
  String get analyticsLevelDistribution => 'Distribuzione livelli';

  @override
  String get memoryFlashTitle => 'Memory Flash';

  @override
  String get memoryFlashStart => 'Inizia';

  @override
  String get memoryFlashPlayAgain => 'Gioca ancora';

  @override
  String get memoryFlashWatchSequence => 'Guarda la sequenza…';

  @override
  String get memoryFlashYourTurn => 'Tocca a te!';

  @override
  String memoryFlashLevel(int level) {
    return 'Livello $level';
  }

  @override
  String get memoryFlashGameOver => 'Game Over';

  @override
  String memoryFlashResult(int level) {
    return 'Livello raggiunto: $level';
  }

  @override
  String get memoryFlashFlashSpeed => 'Velocità di lampeggio';

  @override
  String get memoryFlashSpeedSlow => 'Lento';

  @override
  String get memoryFlashSpeedNormal => 'Normale';

  @override
  String get memoryFlashSpeedFast => 'Veloce';

  @override
  String get memoryFlashProEndlessTitle => 'La modalità infinita è Pro';

  @override
  String get memoryFlashProEndlessMessage =>
      'La modalità gratuita è limitata a 10 livelli. Passa a Pro per giocare senza limiti.';

  @override
  String get memoryFlashProSpeedTitle => 'La velocità regolabile è Pro';

  @override
  String get memoryFlashProSpeedMessage =>
      'Passa a Pro per regolare la velocità di lampeggio.';

  @override
  String get memoryFlashFreeProHint =>
      'Gratuito: Fino a 10 livelli.\nPro: Modalità infinita + velocità regolabile.';

  @override
  String memoryFlashSequenceLength(int length) {
    return 'Sequenza: $length';
  }

  @override
  String get generatorCard => 'Carte';

  @override
  String get cardTitle => 'Carte';

  @override
  String get cardTapDraw => 'Tocca \"Pesca\" per pescare una carta';

  @override
  String get cardDraw => 'Pesca';

  @override
  String get cardSectionOptions => 'Opzioni';

  @override
  String get cardIncludeJokers => 'Includi jolly';

  @override
  String get cardIncludeJokersSubtitle => 'Aggiungi due jolly al mazzo';

  @override
  String get cardIncludeJokersProTitle => 'I jolly sono Pro';

  @override
  String get cardIncludeJokersProMessage =>
      'Passa a Pro per aggiungere i jolly al mazzo.';

  @override
  String get cardMultiDrawCount => 'Carte per pescata';

  @override
  String get cardMultiDrawProTitle => 'Pesca multipla è Pro';

  @override
  String get cardMultiDrawProMessage =>
      'Passa a Pro per pescare più carte insieme.';

  @override
  String get cardFreeProHint =>
      'Gratis: una carta.\nPro: jolly + pesca multipla.';

  @override
  String get analyticsBestAccuracy => 'Migliore accuratezza';

  @override
  String get analyticsAvgAccuracy => 'Accuratezza media';

  @override
  String get generatorColorReflex => 'Riflessi colore';

  @override
  String get colorReflexInstructions =>
      'Tocca il colore del TESTO, non la parola!';

  @override
  String get colorReflexDescription =>
      'Usa l\'effetto Stroop per testare i tuoi riflessi.';

  @override
  String get colorReflexDurationLabel => 'Durata';

  @override
  String get colorReflexGetReady => 'Preparati!';

  @override
  String get colorReflexTapPrompt => 'Tocca il COLORE del testo sopra';

  @override
  String get colorReflexTimeUp => 'Tempo scaduto!';

  @override
  String get colorReflexCorrectLabel => 'Corrette';

  @override
  String get colorReflexWrongLabel => 'Errate';

  @override
  String get colorReflexAccuracyLabel => 'Accuratezza';

  @override
  String get colorReflexAvgReactionLabel => 'Reazione media';

  @override
  String get colorReflexPlayAgain => 'Gioca di nuovo';

  @override
  String get colorReflexBackToMenu => 'Torna al menu';

  @override
  String get colorReflexDurationProTitle => 'Durata personalizzata è Pro';

  @override
  String get colorReflexDurationProMessage =>
      'Passa a Pro per scegliere tra durate di 15s, 30s e 60s.';

  @override
  String get colorReflexFreeProHint =>
      'Gratis: 30 secondi fissi.\nPro: scegli 15s, 30s o 60s.';

  @override
  String get tapChallengeTitle => 'Sfida di tocchi';

  @override
  String get tapChallengeInstructions =>
      'Tocca il più velocemente possibile quando appare VIA!';

  @override
  String get tapChallengeStart => 'Inizia';

  @override
  String get tapChallengeAgain => 'Riprova';

  @override
  String get tapChallengeTaps => 'Tocchi';

  @override
  String get tapChallengeTPS => 'Tocchi/sec';

  @override
  String get tapChallengePersonalBest => 'Record personale';

  @override
  String get tapChallengeDurationLabel => 'Durata';

  @override
  String tapChallengeDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get tapChallengeDurationProTitle => 'Durata personalizzata è Pro';

  @override
  String get tapChallengeDurationProMessage =>
      'Passa a Pro per impostare la durata a 5s, 10s, 15s, 30s o 60s.';

  @override
  String get tapChallengeVibrateOnGo => 'Vibra al VIA';

  @override
  String get tapChallengeVibrateOnEnd => 'Vibra alla fine';

  @override
  String get tapChallengeFreeProHint =>
      'Gratis: prova da 5 secondi.\nPro: scegli la durata (5s, 10s, 15s, 30s, 60s) + analisi avanzate.';

  @override
  String get tapChallengeGo => 'VIA!';

  @override
  String get tapChallengeGetReady => 'Preparati';

  @override
  String get tapChallengeResultTitle => 'Sessione completata!';

  @override
  String get tapChallengeAnalyticsPersonalBest => 'Migliori tocchi';

  @override
  String get tapChallengeAnalyticsAvgTaps => 'Tocchi medi';

  @override
  String get tapChallengeAnalyticsAvgTPS => 'TPS medio';

  @override
  String get tapChallengeAnalyticsBestTPS => 'TPS migliore';

  @override
  String get mathChallengeTitle => 'Sfida matematica';

  @override
  String get mathDifficulty => 'Difficoltà';

  @override
  String get mathDifficultyEasy => 'Facile';

  @override
  String get mathDifficultyHard => 'Difficile';

  @override
  String get mathDifficultyProTitle => 'Modalità difficile è Pro';

  @override
  String get mathDifficultyProMessage =>
      'Passa a Pro per sbloccare moltiplicazione, divisione e numeri più grandi.';

  @override
  String get mathDuration => 'Durata';

  @override
  String mathDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get mathDurationFree => 'Fisso: 30 secondi';

  @override
  String get mathDurationProTitle => 'Durata personalizzata è Pro';

  @override
  String get mathDurationProMessage =>
      'Passa a Pro per selezionare una durata personalizzata da 15 a 60 secondi.';

  @override
  String get mathStart => 'Inizia';

  @override
  String get mathTimeLeft => 'Tempo';

  @override
  String get mathCorrect => 'Corrette';

  @override
  String get mathWrong => 'Errate';

  @override
  String get mathResultTitle => 'Risultati';

  @override
  String get mathAccuracy => 'Accuratezza';

  @override
  String get mathPPS => 'Al secondo';

  @override
  String get mathPlayAgain => 'Gioca di nuovo';

  @override
  String get mathBackToMenu => 'Torna al menu';

  @override
  String get mathFreeProHint =>
      'Gratis: addizione e sottrazione, 30 secondi.\nPro: tutte le operazioni, durata personalizzata.';

  @override
  String get mathAvgAccuracy => 'Accuratezza media';

  @override
  String get generatorTicTacToe => 'Tris';

  @override
  String get generatorConnectFour => 'Forza 4';

  @override
  String get gameSetupTitle => 'Impostazioni Gioco';

  @override
  String get gameModeLabel => 'Modalità di Gioco';

  @override
  String get gameModeBot => 'Gioca contro Bot';

  @override
  String get gameModeLocal => 'Multigiocatore Locale';

  @override
  String get gameModePro => 'Pro';

  @override
  String get gameDifficultyLabel => 'Difficoltà';

  @override
  String get gameDifficultyEasy => 'Facile';

  @override
  String get gameDifficultyMedium => 'Medio';

  @override
  String get gameDifficultyHard => 'Difficile';

  @override
  String get gameDifficultyProTitle => 'Selezione difficoltà è Pro';

  @override
  String get gameDifficultyProMessage =>
      'Vai Pro per scegliere tra Medio e Difficile.';

  @override
  String get gameLocalMultiplayerProTitle => 'Multigiocatore locale è Pro';

  @override
  String get gameLocalMultiplayerProMessage =>
      'Vai Pro per giocare con un amico sullo stesso dispositivo, usare nomi personalizzati e tenere traccia delle statistiche.';

  @override
  String get gameCustomNamesProTitle => 'Nomi personalizzati è Pro';

  @override
  String get gameCustomNamesProMessage =>
      'Vai Pro per inserire nomi di giocatori personalizzati.';

  @override
  String get gamePlayerOneName => 'Nome Giocatore 1';

  @override
  String get gamePlayerTwoName => 'Nome Giocatore 2';

  @override
  String get gamePlayerNameHint => 'Inserisci nome';

  @override
  String get gameStartGame => 'Inizia Gioco';

  @override
  String gamePlayerTurn(String name) {
    return 'Turno di $name';
  }

  @override
  String get gameBotThinking => 'BOT STA PENSANDO...';

  @override
  String gameYouWin(String name) {
    return '$name Vince!';
  }

  @override
  String get gameDraw => 'Pareggio!';

  @override
  String get gamePlayAgain => 'Gioca di nuovo';

  @override
  String get gameBackToSetup => 'Torna alle impostazioni';

  @override
  String get gameStatsTitle => 'Statistiche';

  @override
  String get gameStatsProTitle => 'Le statistiche sono Pro';

  @override
  String get gameStatsProMessage =>
      'Vai Pro per tenere traccia delle vittorie per giocatore tra le sessioni.';

  @override
  String gameStatsWins(int wins) {
    return '$wins vittorie';
  }

  @override
  String get gameStatsClear => 'Cancella statistiche';

  @override
  String get gameStatsClearConfirm =>
      'Cancellare tutte le statistiche di questo gioco?';

  @override
  String get gameStatsNoData =>
      'Ancora nessuna statistica. Gioca una partita per iniziare a tenere traccia delle vittorie!';

  @override
  String get gameStatsDraws => 'Pareggi';

  @override
  String get gameTopPlayers => 'Top Giocatori';

  @override
  String get gameFreeProHint =>
      'Gratis: gioca contro Bot.\nPro: multigiocatore locale, nomi personalizzati, selezione difficoltà e statistiche.';

  @override
  String get gameStatsBot => 'BOT';

  @override
  String get gameStatsPlayer => 'GIOCATORE';

  @override
  String get gameInfinityMode => 'Modalità Infinito';

  @override
  String get gameInfinityModeSubtitle =>
      'Ogni giocatore mantiene al massimo 3 segni – il più vecchio viene rimosso al 4° turno. Nessun pareggio!';
}
