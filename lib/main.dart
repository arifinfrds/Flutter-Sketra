import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'data/cache/favorite_wallpaper_store.dart';
import 'pages/feed/feed_page_proxy.dart';

late HiveFavoriteWallpaperStore favoriteStore;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  favoriteStore = HiveFavoriteWallpaperStore();
  await favoriteStore.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sketra',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const FeedPageProxy(title: 'Sketra'),
    );
  }
}