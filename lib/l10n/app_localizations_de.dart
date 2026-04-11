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
  String get generatorMemoryFlash => 'Memory Flash';

  @override
  String get generatorTapChallenge => 'Tipp-Challenge';

  @override
  String get generatorMathChallenge => 'Mathe-Challenge';

  @override
  String get commonGenerate => 'Generieren';

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
  String get settingsRateApp => 'App bewerten';

  @override
  String get settingsShareApp => 'App teilen';

  @override
  String get settingsShareAppSubtitle => 'Freunde zu Picksy einladen';

  @override
  String get settingsCompareFreePro => 'Kostenlos vs. Pro vergleichen';

  @override
  String get compareTitle => 'Kostenlos vs. Pro';

  @override
  String get compareFeatureLabel => 'Funktion';

  @override
  String get compareFreeColumn => 'Kostenlos';

  @override
  String get compareProColumn => 'Pro';

  @override
  String get compareFeatureHistory => 'Verlauf';

  @override
  String get compareFreeHistory => '3 Ergebnisse';

  @override
  String get compareProHistory => '1000 Ergebnisse';

  @override
  String get compareFeatureFavorites => 'Favoriten';

  @override
  String get compareFreeFavorites => 'Bis zu 2';

  @override
  String get compareProFavorites => 'Bis zu 999';

  @override
  String get compareFeatureColorModes => 'Farbfunktionen';

  @override
  String get compareFeatureCustomRange => 'Zahlenfunktionen';

  @override
  String get compareFeatureCustomListExtras => 'Eigene Liste';

  @override
  String get compareFeatureTimeRange => 'Zeitbereich';

  @override
  String get compareFeatureLetterFilters => 'Buchstabenfilter';

  @override
  String get compareFeatureBottleHaptics => 'Flaschendrehen-Steuerung';

  @override
  String get compareFeatureAnalytics => 'Analytik';

  @override
  String get proPromoCode => 'Promo-Code';

  @override
  String get proPromoCodeHint => 'Promo-Code eingeben';

  @override
  String get proPromoCodeApply => 'Einlösen';

  @override
  String get proPromoCodeSuccess =>
      'Promo-Code eingelöst! Pro ist jetzt aktiv.';

  @override
  String get proPromoCodeInvalid =>
      'Ungültiger Promo-Code. Bitte erneut versuchen.';

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
  String get proLifetimeFallbackPrice => '€5.49 one-time';

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
  String get bottleSpinSpinning => 'Spinning...';

  @override
  String get bottleSpinSpin => 'Spin';

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
  String get timeStop => 'Stopp';

  @override
  String get timeHideTime => 'Zeit ausblenden';

  @override
  String get timeRangeSeconds => 'Bereich (Sekunden)';

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
  String get hangmanDescription => 'Rate das Wort Buchstabe für Buchstabe';

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
  String hangmanAttemptsLeft(int count) {
    return 'Versuche übrig: $count';
  }

  @override
  String get hangmanWrongLetters => 'Falsche Buchstaben:';

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
  String get analyticsAvgLevel => 'Durchschn. Level';

  @override
  String get analyticsLevelDistribution => 'Level-Verteilung';

  @override
  String get memoryFlashTitle => 'Memory Flash';

  @override
  String get memoryFlashDescription =>
      'Schau dir die Reihenfolge an und wiederhole sie';

  @override
  String get memoryFlashStart => 'Start';

  @override
  String get memoryFlashPlayAgain => 'Nochmal spielen';

  @override
  String get memoryFlashBackToMenu => 'Zurück zum Menü';

  @override
  String get memoryFlashWatchSequence => 'Sequenz beobachten…';

  @override
  String get memoryFlashYourTurn => 'Du bist dran!';

  @override
  String memoryFlashLevel(int level) {
    return 'Level $level';
  }

  @override
  String get memoryFlashGameOver => 'Spiel vorbei';

  @override
  String memoryFlashResult(int level) {
    return 'Erreichtes Level: $level';
  }

  @override
  String get memoryFlashBlocks => 'Blöcke';

  @override
  String get memoryFlashFlashSpeed => 'Blitzgeschwindigkeit';

  @override
  String get memoryFlashSpeedSlow => 'Langsam';

  @override
  String get memoryFlashSpeedNormal => 'Normal';

  @override
  String get memoryFlashSpeedFast => 'Schnell';

  @override
  String get memoryFlashProEndlessTitle => 'Endlosmodus ist Pro';

  @override
  String get memoryFlashProEndlessMessage =>
      'Im kostenlosen Modus sind maximal 10 Level möglich. Werde Pro für endloses Spielen.';

  @override
  String get memoryFlashProSpeedTitle => 'Einstellbare Geschwindigkeit ist Pro';

  @override
  String get memoryFlashProSpeedMessage =>
      'Werde Pro, um die Blitzgeschwindigkeit anzupassen.';

  @override
  String memoryFlashSequenceLength(int length) {
    return 'Sequenz: $length';
  }

  @override
  String get generatorCard => 'Karte ziehen';

  @override
  String get cardTitle => 'Karte ziehen';

  @override
  String get cardTapDraw => '\"Ziehen\" tippen, um eine Karte zu ziehen';

  @override
  String get cardDraw => 'Ziehen';

  @override
  String get cardSectionOptions => 'Optionen';

  @override
  String get cardIncludeJokers => 'Joker einbeziehen';

  @override
  String get cardIncludeJokersSubtitle => 'Zwei Joker zum Stapel hinzufügen';

  @override
  String get cardIncludeJokersProTitle => 'Joker sind Pro';

  @override
  String get cardIncludeJokersProMessage => 'Werde Pro, um Joker hinzuzufügen.';

  @override
  String get cardMultiDrawCount => 'Karten pro Zug';

  @override
  String get cardMultiDrawProTitle => 'Mehrfachzug ist Pro';

  @override
  String get cardMultiDrawProMessage =>
      'Werde Pro, um mehrere Karten auf einmal zu ziehen.';

  @override
  String get cardFreeProHint =>
      'Kostenlos: Einzelzug.\nPro: Joker + Mehrfachzug.';

  @override
  String get analyticsBestAccuracy => 'Beste Genauigkeit';

  @override
  String get analyticsAvgAccuracy => 'Ø Genauigkeit';

  @override
  String get generatorColorReflex => 'Farbreflexe';

  @override
  String get colorReflexInstructions =>
      'Tippe auf die Farbe des TEXTES, nicht auf das Wort!';

  @override
  String get colorReflexDescription =>
      'Nutzt den Stroop-Effekt, um deine Reflexe zu testen.';

  @override
  String get colorReflexDurationLabel => 'Dauer';

  @override
  String get colorReflexGetReady => 'Mach dich bereit!';

  @override
  String get colorReflexTapPrompt => 'Tippe auf die FARBE des Textes oben';

  @override
  String get colorReflexTimeUp => 'Zeit abgelaufen!';

  @override
  String get colorReflexCorrectLabel => 'Richtig';

  @override
  String get colorReflexWrongLabel => 'Falsch';

  @override
  String get colorReflexAccuracyLabel => 'Genauigkeit';

  @override
  String get colorReflexAvgReactionLabel => 'Ø Reaktion';

  @override
  String get colorReflexPlayAgain => 'Nochmal spielen';

  @override
  String get colorReflexBackToMenu => 'Zurück zum Menü';

  @override
  String get colorReflexDurationProTitle => 'Individuelle Dauer ist Pro';

  @override
  String get colorReflexDurationProMessage =>
      'Upgrade auf Pro, um zwischen 15s, 30s und 60s zu wählen.';

  @override
  String get colorReflexFreeProHint =>
      'Gratis: 30 Sekunden fest.\nPro: wähle 15s, 30s oder 60s.';

  @override
  String get tapChallengeTitle => 'Tipp-Challenge';

  @override
  String get tapChallengeInstructions =>
      'Tippe so schnell wie möglich, wenn GO erscheint!';

  @override
  String get tapChallengeStart => 'Start';

  @override
  String get tapChallengeAgain => 'Nochmal';

  @override
  String get tapChallengeTaps => 'Tipps';

  @override
  String get tapChallengeTPS => 'Tipps/Sek';

  @override
  String get tapChallengePersonalBest => 'Persönliche Bestleistung';

  @override
  String get tapChallengeDurationLabel => 'Dauer';

  @override
  String tapChallengeDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get tapChallengeDurationProTitle => 'Benutzerdefinierte Dauer ist Pro';

  @override
  String get tapChallengeDurationProMessage =>
      'Werde Pro, um die Challenge-Dauer auf 5s, 10s, 15s, 30s oder 60s einzustellen.';

  @override
  String get tapChallengeGo => 'LOS!';

  @override
  String get tapChallengeGetReady => 'Bereit machen';

  @override
  String get tapChallengeResultTitle => 'Run abgeschlossen!';

  @override
  String get tapChallengeAnalyticsPersonalBest => 'Beste Tipps';

  @override
  String get tapChallengeAnalyticsAvgTaps => 'Ø Tipps';

  @override
  String get tapChallengeAnalyticsAvgTPS => 'Ø TPS';

  @override
  String get tapChallengeAnalyticsBestTPS => 'Beste TPS';

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
  String get mathDifficultyProMessage =>
      'Werde Pro, um Multiplikation, Division und größere Zahlen freizuschalten.';

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
  String get mathDurationProMessage =>
      'Werde Pro, um eine Dauer von 15 bis 60 Sekunden zu wählen.';

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
  String get mathFreeProHint =>
      'Free: Addition & Subtraktion, 30 Sekunden.\nPro: alle Operationen, benutzerdefinierte Dauer.';

  @override
  String get mathAvgAccuracy => 'Durchschn. Genauigkeit';

  @override
  String get generatorTicTacToe => 'Tic Tac Toe';

  @override
  String get ticTacToeDescription => 'Klassisches 3×3-Spiel mit X und O';

  @override
  String get connectFourDescription =>
      'Klassisches 7×6-Strategiespiel – 4 in Reihe gewinnt';

  @override
  String get mathChallengeDescription =>
      'Löse Matheaufgaben so schnell wie möglich';

  @override
  String get generatorConnectFour => 'Vier gewinnt';

  @override
  String get gameSetupTitle => 'Spieleinstellungen';

  @override
  String get gameModeLabel => 'Spielmodus';

  @override
  String get gameModeBot => 'Gegen Bot spielen';

  @override
  String get gameModeLocal => 'Lokaler Mehrspieler';

  @override
  String get gameModePro => 'Pro';

  @override
  String get gameDifficultyLabel => 'Schwierigkeit';

  @override
  String get gameDifficultyEasy => 'Leicht';

  @override
  String get gameDifficultyMedium => 'Mittel';

  @override
  String get gameDifficultyHard => 'Schwer';

  @override
  String get gameDifficultyProTitle => 'Schwierigkeitswahl ist Pro';

  @override
  String get gameDifficultyProMessage =>
      'Werde Pro, um zwischen Mittel und Schwer zu wählen.';

  @override
  String get gameLocalMultiplayerProTitle => 'Lokaler Mehrspieler ist Pro';

  @override
  String get gameLocalMultiplayerProMessage =>
      'Werde Pro, um mit einem Freund auf demselben Gerät zu spielen, eigene Namen zu nutzen und Statistiken zu verfolgen.';

  @override
  String get gameCustomNamesProTitle => 'Eigene Namen ist Pro';

  @override
  String get gameCustomNamesProMessage =>
      'Werde Pro, um eigene Spielernamen einzugeben.';

  @override
  String get gamePlayerOneName => 'Name Spieler 1';

  @override
  String get gamePlayerTwoName => 'Name Spieler 2';

  @override
  String get gamePlayerNameHint => 'Name eingeben';

  @override
  String get gameStartGame => 'Spiel starten';

  @override
  String gamePlayerTurn(String name) {
    return '$name ist dran';
  }

  @override
  String get gameBotThinking => 'BOT DENKT...';

  @override
  String gameYouWin(String name) {
    return '$name gewinnt!';
  }

  @override
  String get gameDraw => 'Unentschieden!';

  @override
  String get gamePlayAgain => 'Nochmal spielen';

  @override
  String get gameBackToSetup => 'Zurück zu Einstellungen';

  @override
  String get gameStatsTitle => 'Statistiken';

  @override
  String get gameStatsProTitle => 'Statistiken ist Pro';

  @override
  String get gameStatsProMessage =>
      'Werde Pro, um Siege pro Spieler sitzungsübergreifend zu verfolgen.';

  @override
  String gameStatsWins(int wins) {
    return '$wins Siege';
  }

  @override
  String get gameStatsClear => 'Statistiken löschen';

  @override
  String get gameStatsClearConfirm =>
      'Alle Statistiken für dieses Spiel löschen?';

  @override
  String get gameStatsNoData =>
      'Noch keine Statistiken. Spiele ein Spiel, um Siege zu verfolgen!';

  @override
  String get gameStatsDraws => 'Unentschieden';

  @override
  String get gameTopPlayers => 'Top-Spieler';

  @override
  String get gameFreeProHint =>
      'Free: gegen Bot spielen.\nPro: lokaler Mehrspieler, eigene Namen, Schwierigkeitswahl & Statistiken.';

  @override
  String get gameStatsBot => 'BOT';

  @override
  String get gameStatsPlayer => 'SPIELER';

  @override
  String get gameInfinityMode => 'Infinity-Modus';

  @override
  String get gameInfinityModeSubtitle =>
      'Jeder Spieler behält maximal 3 Steine – beim 4. Zug wird der älteste entfernt. Kein Unentschieden!';
}
