import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'storage/boxes.dart';
import 'storage/settings_store.dart';
import 'storage/favorites_store.dart';
import 'storage/custom_lists_store.dart';
import 'storage/premium_store.dart';
import 'storage/history_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Boxes.init(); // opens Hive boxes

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsStore()),
        ChangeNotifierProvider(create: (_) => FavoritesStore()),
        ChangeNotifierProvider(create: (_) => CustomListsStore()),
        ChangeNotifierProvider(create: (_) => PremiumStore()),
        ChangeNotifierProvider(create: (_) => HistoryStore()),
      ],
      child: const RandomBuilderApp(),
    ),
  );
}

class RandomBuilderApp extends StatelessWidget {
  const RandomBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: settings.themeMode,
      locale: Locale(settings.languageCode),
      supportedLocales: const [Locale('en'), Locale('de')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}
