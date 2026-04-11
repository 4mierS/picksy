// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Picksy';

  @override
  String get navHome => 'Inicio';

  @override
  String get navPro => 'Pro';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navAnalytics => 'Analíticas';

  @override
  String get generatorColor => 'Color';

  @override
  String get generatorNumber => 'Número';

  @override
  String get generatorCoin => 'Moneda';

  @override
  String get generatorLetter => 'Letra';

  @override
  String get generatorCustomList => 'Lista personalizada';

  @override
  String get generatorBottleSpin => 'Botella';

  @override
  String get generatorTime => 'Tiempo';

  @override
  String get generatorReactionTest => 'Test de reacción';

  @override
  String get generatorHangman => 'Ahorcado';

  @override
  String get generatorMemoryFlash => 'Memory Flash';

  @override
  String get generatorTapChallenge => 'Desafío de Toque';

  @override
  String get generatorMathChallenge => 'Desafío Matemático';

  @override
  String get commonGenerate => 'Generar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClear => 'Limpiar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get commonProFeature => 'Función Pro';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Oscuro';

  @override
  String get settingsReportBug => 'Reportar error';

  @override
  String get settingsSuggestFeature => 'Sugerir función';

  @override
  String get settingsSupportPicksy => 'Apoyar Picksy';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsImprint => 'Imprint';

  @override
  String get settingsTermsOfService => 'Términos de servicio';

  @override
  String get settingsRequiresGithub => 'Requiere una cuenta de GitHub';

  @override
  String get settingsProActive => 'Pro activo';

  @override
  String get settingsFreeVersion => 'Versión gratuita';

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
  String get settingsRateApp => 'Valorar la app';

  @override
  String get settingsShareApp => 'Compartir app';

  @override
  String get settingsShareAppSubtitle => 'Invita a amigos a probar Picksy';

  @override
  String get settingsCompareFreePro => 'Comparar Gratis vs Pro';

  @override
  String get compareTitle => 'Gratis vs Pro';

  @override
  String get compareFeatureLabel => 'Función';

  @override
  String get compareFreeColumn => 'Gratis';

  @override
  String get compareProColumn => 'Pro';

  @override
  String get compareFeatureHistory => 'Historial';

  @override
  String get compareFreeHistory => '3 resultados';

  @override
  String get compareProHistory => '1000 resultados';

  @override
  String get compareFeatureFavorites => 'Favoritos';

  @override
  String get compareFreeFavorites => 'Hasta 2';

  @override
  String get compareProFavorites => 'Hasta 999';

  @override
  String get compareFeatureColorModes => 'Funciones de color';

  @override
  String get compareFeatureCustomRange => 'Funciones de número';

  @override
  String get compareFeatureCustomListExtras => 'Lista personalizada';

  @override
  String get compareFeatureTimeRange => 'Rango de tiempo';

  @override
  String get compareFeatureLetterFilters => 'Filtros de letra';

  @override
  String get compareFeatureBottleHaptics => 'Controles de botella';

  @override
  String get compareFeatureAnalytics => 'Analíticas';

  @override
  String get proPromoCode => 'Código promocional';

  @override
  String get proPromoCodeHint => 'Ingresa el código';

  @override
  String get proPromoCodeApply => 'Aplicar';

  @override
  String get proPromoCodeSuccess => '¡Código aplicado! Pro ya está activo.';

  @override
  String get proPromoCodeInvalid => 'Código inválido. Inténtalo de nuevo.';

  @override
  String get homeSmartRandomDecisions => 'Decisiones aleatorias inteligentes';

  @override
  String get homeHistoryTooltip => 'Historial';

  @override
  String get homeFavorites => 'Favoritos';

  @override
  String get homeAllGenerators => 'Todos los generadores';

  @override
  String get homeFavorite => 'Favorito';

  @override
  String get homeUnfavorite => 'Quitar favorito';

  @override
  String get homeTapToOpen => 'Toca para abrir';

  @override
  String get homeFavoritesLimitReachedTitle => 'Favorites limit reached';

  @override
  String get homeFavoritesLimitReachedMessage =>
      'Free users can pin up to 2 generators. Go Pro for unlimited favorites.';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyClearAll => 'Borrar todo';

  @override
  String get historyEmpty => 'Sin historial aún';

  @override
  String historyItemSubtitle(Object generator, Object timestamp) {
    return '$generator • $timestamp';
  }

  @override
  String routerComingNext(Object generator) {
    return 'A continuación: $generator';
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
  String get timeTitle => 'Tiempo aleatorio';

  @override
  String get timeReady => '¿Listo?';

  @override
  String get timeReset => 'Reiniciar';

  @override
  String get timeAgain => 'Otra vez';

  @override
  String get timeStart => 'Iniciar';

  @override
  String get timeStop => 'Detener';

  @override
  String get timeHideTime => 'Ocultar tiempo';

  @override
  String get timeRangeSeconds => 'Rango (segundos)';

  @override
  String get timeRunning => 'En curso…';

  @override
  String get timeHidden => 'Oculto';

  @override
  String timeFormatted(int seconds, Object milliseconds) {
    return '${seconds}s ${milliseconds}ms';
  }

  @override
  String get hangmanTitle => 'Ahorcado';

  @override
  String get hangmanDescription => 'Adivina la palabra letra por letra';

  @override
  String get hangmanNewGame => 'Nuevo juego';

  @override
  String get hangmanPlayAgain => 'Jugar de nuevo';

  @override
  String get hangmanYouWon => '¡Ganaste!';

  @override
  String hangmanYouLost(Object word) {
    return '¡Perdiste! La palabra era: $word';
  }

  @override
  String hangmanAttemptsLeft(int count) {
    return 'Intentos restantes: $count';
  }

  @override
  String get hangmanWrongLetters => 'Letras incorrectas:';

  @override
  String get analyticsTitle => 'Analíticas';

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
    return '$generator Analíticas';
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
  String get analyticsAvgLevel => 'Nivel promedio';

  @override
  String get analyticsLevelDistribution => 'Distribución de niveles';

  @override
  String get memoryFlashTitle => 'Memory Flash';

  @override
  String get memoryFlashDescription => 'Observa la secuencia y repítela';

  @override
  String get memoryFlashStart => 'Iniciar';

  @override
  String get memoryFlashPlayAgain => 'Jugar de nuevo';

  @override
  String get memoryFlashBackToMenu => 'Volver al menú';

  @override
  String get memoryFlashWatchSequence => 'Observa la secuencia…';

  @override
  String get memoryFlashYourTurn => '¡Tu turno!';

  @override
  String memoryFlashLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get memoryFlashGameOver => 'Fin del juego';

  @override
  String memoryFlashResult(int level) {
    return 'Nivel alcanzado: $level';
  }

  @override
  String get memoryFlashBlocks => 'Bloques';

  @override
  String get memoryFlashFlashSpeed => 'Velocidad de destello';

  @override
  String get memoryFlashSpeedSlow => 'Lento';

  @override
  String get memoryFlashSpeedNormal => 'Normal';

  @override
  String get memoryFlashSpeedFast => 'Rápido';

  @override
  String get memoryFlashProEndlessTitle => 'El modo sin fin es Pro';

  @override
  String get memoryFlashProEndlessMessage =>
      'El modo gratuito está limitado a 10 niveles. Hazte Pro para jugar sin límite.';

  @override
  String get memoryFlashProSpeedTitle => 'La velocidad ajustable es Pro';

  @override
  String get memoryFlashProSpeedMessage =>
      'Hazte Pro para ajustar la velocidad de destello.';

  @override
  String memoryFlashSequenceLength(int length) {
    return 'Secuencia: $length';
  }

  @override
  String get generatorCard => 'Sacar carta';

  @override
  String get cardTitle => 'Sacar carta';

  @override
  String get cardTapDraw => 'Toca \"Sacar\" para obtener una carta';

  @override
  String get cardDraw => 'Sacar';

  @override
  String get cardSectionOptions => 'Opciones';

  @override
  String get cardIncludeJokers => 'Incluir comodines';

  @override
  String get cardIncludeJokersSubtitle => 'Añadir dos comodines al mazo';

  @override
  String get cardIncludeJokersProTitle => 'Los comodines son Pro';

  @override
  String get cardIncludeJokersProMessage =>
      'Hazte Pro para añadir comodines al mazo.';

  @override
  String get cardMultiDrawCount => 'Cartas por extracción';

  @override
  String get cardMultiDrawProTitle => 'Sacar múltiples es Pro';

  @override
  String get cardMultiDrawProMessage =>
      'Hazte Pro para sacar varias cartas a la vez.';

  @override
  String get cardFreeProHint =>
      'Gratis: Una carta.\nPro: Comodines + sacar múltiples.';

  @override
  String get analyticsBestAccuracy => 'Mejor precisión';

  @override
  String get analyticsAvgAccuracy => 'Precisión media';

  @override
  String get generatorColorReflex => 'Reflejo de Color';

  @override
  String get colorReflexInstructions =>
      '¡Toca el color del TEXTO, no de la palabra!';

  @override
  String get colorReflexDescription =>
      'Usa el Efecto Stroop para poner a prueba tus reflejos.';

  @override
  String get colorReflexDurationLabel => 'Duración';

  @override
  String get colorReflexGetReady => '¡Prepárate!';

  @override
  String get colorReflexTapPrompt => 'Toca el COLOR del texto de arriba';

  @override
  String get colorReflexTimeUp => '¡Tiempo!';

  @override
  String get colorReflexCorrectLabel => 'Correcto';

  @override
  String get colorReflexWrongLabel => 'Incorrecto';

  @override
  String get colorReflexAccuracyLabel => 'Precisión';

  @override
  String get colorReflexAvgReactionLabel => 'Reacción media';

  @override
  String get colorReflexPlayAgain => 'Jugar de nuevo';

  @override
  String get colorReflexBackToMenu => 'Volver al menú';

  @override
  String get colorReflexDurationProTitle => 'La duración personalizada es Pro';

  @override
  String get colorReflexDurationProMessage =>
      'Hazte Pro para elegir entre 15s, 30s y 60s.';

  @override
  String get colorReflexFreeProHint =>
      'Gratis: 30 segundos fijo.\nPro: elige 15s, 30s o 60s.';

  @override
  String get tapChallengeTitle => 'Desafío de Toque';

  @override
  String get tapChallengeInstructions =>
      '¡Toca lo más rápido posible cuando aparezca GO!';

  @override
  String get tapChallengeStart => 'Iniciar';

  @override
  String get tapChallengeAgain => 'Intentar de Nuevo';

  @override
  String get tapChallengeTaps => 'Toques';

  @override
  String get tapChallengeTPS => 'Toques/seg';

  @override
  String get tapChallengePersonalBest => 'Mejor Personal';

  @override
  String get tapChallengeDurationLabel => 'Duración';

  @override
  String tapChallengeDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get tapChallengeDurationProTitle => 'Duración personalizada es Pro';

  @override
  String get tapChallengeDurationProMessage =>
      'Hazte Pro para configurar la duración a 5s, 10s, 15s, 30s o 60s.';

  @override
  String get tapChallengeGo => '¡VAMOS!';

  @override
  String get tapChallengeGetReady => 'Prepárate';

  @override
  String get tapChallengeResultTitle => '¡Carrera completada!';

  @override
  String get tapChallengeAnalyticsPersonalBest => 'Mejores Toques';

  @override
  String get tapChallengeAnalyticsAvgTaps => 'Prom. Toques';

  @override
  String get tapChallengeAnalyticsAvgTPS => 'Prom. TPS';

  @override
  String get tapChallengeAnalyticsBestTPS => 'Mejor TPS';

  @override
  String get mathChallengeTitle => 'Desafío Matemático';

  @override
  String get mathDifficulty => 'Dificultad';

  @override
  String get mathDifficultyEasy => 'Fácil';

  @override
  String get mathDifficultyHard => 'Difícil';

  @override
  String get mathDifficultyProTitle => 'El modo difícil es Pro';

  @override
  String get mathDifficultyProMessage =>
      'Hazte Pro para desbloquear multiplicación, división y números más grandes.';

  @override
  String get mathDuration => 'Duración';

  @override
  String mathDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get mathDurationFree => 'Fijo: 30 segundos';

  @override
  String get mathDurationProTitle => 'Duración personalizada es Pro';

  @override
  String get mathDurationProMessage =>
      'Hazte Pro para elegir una duración de 15 a 60 segundos.';

  @override
  String get mathStart => 'Iniciar';

  @override
  String get mathTimeLeft => 'Tiempo';

  @override
  String get mathCorrect => 'Correcto';

  @override
  String get mathWrong => 'Incorrecto';

  @override
  String get mathResultTitle => 'Resultados';

  @override
  String get mathAccuracy => 'Precisión';

  @override
  String get mathPPS => 'Por seg.';

  @override
  String get mathPlayAgain => 'Jugar de nuevo';

  @override
  String get mathBackToMenu => 'Volver al menú';

  @override
  String get mathFreeProHint =>
      'Free: suma y resta, 30 segundos.\nPro: todas las operaciones, duración personalizada.';

  @override
  String get mathAvgAccuracy => 'Precisión media';

  @override
  String get generatorTicTacToe => 'Tres en Raya';

  @override
  String get ticTacToeDescription => 'El clásico juego 3×3 de X y O';

  @override
  String get connectFourDescription =>
      'El clásico juego de estrategia 7×6 – conecta 4 para ganar';

  @override
  String get mathChallengeDescription =>
      'Resuelve problemas matemáticos lo más rápido que puedas';

  @override
  String get generatorConnectFour => 'Conecta Cuatro';

  @override
  String get gameSetupTitle => 'Configuración';

  @override
  String get gameModeLabel => 'Modo de Juego';

  @override
  String get gameModeBot => 'Jugar contra Bot';

  @override
  String get gameModeLocal => 'Multijugador Local';

  @override
  String get gameModePro => 'Pro';

  @override
  String get gameDifficultyLabel => 'Dificultad';

  @override
  String get gameDifficultyEasy => 'Fácil';

  @override
  String get gameDifficultyMedium => 'Medio';

  @override
  String get gameDifficultyHard => 'Difícil';

  @override
  String get gameDifficultyProTitle => 'La selección de dificultad es Pro';

  @override
  String get gameDifficultyProMessage =>
      'Hazte Pro para elegir entre Medio y Difícil.';

  @override
  String get gameLocalMultiplayerProTitle => 'Multijugador local es Pro';

  @override
  String get gameLocalMultiplayerProMessage =>
      'Hazte Pro para jugar con un amigo en el mismo dispositivo, usar nombres personalizados y rastrear estadísticas.';

  @override
  String get gameCustomNamesProTitle => 'Nombres personalizados es Pro';

  @override
  String get gameCustomNamesProMessage =>
      'Hazte Pro para introducir nombres de jugadores personalizados.';

  @override
  String get gamePlayerOneName => 'Nombre Jugador 1';

  @override
  String get gamePlayerTwoName => 'Nombre Jugador 2';

  @override
  String get gamePlayerNameHint => 'Introduce nombre';

  @override
  String get gameStartGame => 'Iniciar Juego';

  @override
  String gamePlayerTurn(String name) {
    return 'Turno de $name';
  }

  @override
  String get gameBotThinking => 'BOT PENSANDO...';

  @override
  String gameYouWin(String name) {
    return '¡$name Gana!';
  }

  @override
  String get gameDraw => '¡Empate!';

  @override
  String get gamePlayAgain => 'Jugar de nuevo';

  @override
  String get gameBackToSetup => 'Volver a configuración';

  @override
  String get gameStatsTitle => 'Estadísticas';

  @override
  String get gameStatsProTitle => 'Las estadísticas son Pro';

  @override
  String get gameStatsProMessage =>
      'Hazte Pro para rastrear victorias por jugador entre sesiones.';

  @override
  String gameStatsWins(int wins) {
    return '$wins victorias';
  }

  @override
  String get gameStatsClear => 'Borrar estadísticas';

  @override
  String get gameStatsClearConfirm =>
      '¿Borrar todas las estadísticas de este juego?';

  @override
  String get gameStatsNoData =>
      'Sin estadísticas aún. ¡Juega una partida para empezar a rastrear victorias!';

  @override
  String get gameStatsDraws => 'Empates';

  @override
  String get gameTopPlayers => 'Mejores Jugadores';

  @override
  String get gameFreeProHint =>
      'Free: jugar contra Bot.\nPro: multijugador local, nombres personalizados, selección de dificultad y estadísticas.';

  @override
  String get gameStatsBot => 'BOT';

  @override
  String get gameStatsPlayer => 'JUGADOR';

  @override
  String get gameInfinityMode => 'Modo Infinito';

  @override
  String get gameInfinityModeSubtitle =>
      'Cada jugador mantiene máximo 3 marcas – la más antigua se elimina en el 4.º movimiento. ¡Sin empates!';
}
