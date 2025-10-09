import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:sketra/pages/favorites/favorites_view_model.dart';
import 'package:sketra/pages/tab/main_tab_view.dart';

import 'data/cache/favorite_wallpaper_store.dart';
import 'data/domain/check_is_favorite_wallpaper_use_case.dart';
import 'data/domain/load_favorite_wallpapers_use_case.dart';
import 'data/networking/json_wallpaper_service.dart';

late HiveFavoriteWallpaperStore favoriteStore;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final store = HiveFavoriteWallpaperStore();
  await store.init();

  final jsonString = await rootBundle.loadString('assets/feed-v1.json');
  final wallpaperService = JsonWallpaperService.name(jsonString);

  final checkIsFavoriteUseCase = DefaultCheckIsFavoriteWallpaperUseCase(store);
  final loadFavoriteWallpapersUseCase = DefaultLoadFavoriteWallpapersUseCase(
    wallpaperService: wallpaperService,
    checkIsFavoriteWallpaperUseCase: checkIsFavoriteUseCase,
  );

  final favoritesViewModel = FavoritesViewModel(
    loadFavoriteWallpapersUseCase: loadFavoriteWallpapersUseCase,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<JsonWallpaperService>.value(value: wallpaperService),
        Provider<HiveFavoriteWallpaperStore>.value(value: store),
        Provider<CheckIsFavoriteWallpaperUseCase>.value(value: checkIsFavoriteUseCase),
        Provider<LoadFavoriteWallpapersUseCase>.value(value: loadFavoriteWallpapersUseCase),
        ChangeNotifierProvider<FavoritesViewModel>.value(value: favoritesViewModel),
      ],
      child: const MyApp(),
    ),
  );
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
      home: MainTabView(),
    );
  }
}