import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketra/pages/favorites/favorites_view_model.dart';

import '../../data/cache/favorite_wallpaper_store.dart';
import '../../data/domain/check_is_favorite_wallpaper_use_case.dart';
import '../../data/domain/favorite_wallpaper_use_case.dart';
import '../../data/domain/unfavorite_wallpaper_use_case.dart';
import '../../data/domain/wallpaper_entity.dart';
import '../../data/networking/download_wallpaper_service.dart';
import '../../data/networking/json_wallpaper_service.dart';
import '../detail/feed_detail_page.dart';
import '../detail/feed_detail_view_model.dart';
import '../feed/feed_page_grid_cell.dart';
import '../shared/content_unavailable_view.dart';
import 'favorites_page_toggle_adapter.dart';

typedef ViewState = FavoritesViewModelViewState;

class FavoritesPage extends StatelessWidget {
  final FavoritesViewModel viewModel;

  const FavoritesPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    viewModel.onLoad();

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: _FavoritesPageContent(),
    );
  }
}

class _FavoritesPageContent extends StatelessWidget {
  const _FavoritesPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavoritesViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _body(context, viewModel),
    );
  }

  Widget _body(BuildContext context, FavoritesViewModel viewModel) {
    switch (viewModel.viewState) {
      case ViewState.loading || ViewState.initial:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return _errorView(viewModel);
      case ViewState.favoriteUnfavoriteOperationError:
        final errorMessage = viewModel.errorMessage;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final snackBar = SnackBar(content: Text(errorMessage));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
        return _gridView(viewModel.wallpapers, viewModel);
      case ViewState.empty:
        return const Center(child: Text("No wallpapers available"));
      case ViewState.loaded || ViewState.pullToRefreshLoading:
        return RefreshIndicator(
          child: _gridView(viewModel.wallpapers, viewModel),
          onRefresh: () => viewModel.onReload(),
        );
    }
  }

  Widget _errorView(FavoritesViewModel viewModel) {
    return ContentUnavailableView.name(
      title: "Failed to load favorite wallpapers",
      description: viewModel.errorMessage,
      onRetry: () => viewModel.onLoad(),
    );
  }

  GridView _gridView(
    List<WallpaperEntity> wallpapers,
    FavoritesViewModel viewModel,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        return _feedPageGridCell(context, viewModel, wallpapers[index]);
      },
    );
  }

  Widget _feedPageGridCell(
    BuildContext context,
    FavoritesViewModel viewModel,
    WallpaperEntity wallpaper,
  ) {
    return FeedPageGridCell(
      wallpaper: wallpaper,
      onTap: () => _showFeedDetailPage(context, viewModel, wallpaper),
      isFavorite: viewModel.wallpapers.contains(wallpaper),
      onToggleFavorite: () => viewModel.toggleFavorite(wallpaper),
    );
  }

  Future<dynamic> _showFeedDetailPage(
    BuildContext context,
    FavoritesViewModel _,
    WallpaperEntity wallpaper,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          final favoriteWallpaperStore = context
              .read<HiveFavoriteWallpaperStore>();
          final wallpaperService = context.read<JsonWallpaperService>();
          final favoritesViewModel = context.read<FavoritesViewModel>();

          final detailViewModel = FeedDetailViewModel(
            wallpaper.id,
            wallpaperService,
            DownloadWallpaperService(),
            DefaultCheckIsFavoriteWallpaperUseCase(favoriteWallpaperStore),
            DefaultFavoriteWallpaperUseCase(favoriteWallpaperStore),
            DefaultUnfavoriteWallpaperUseCase(favoriteWallpaperStore),
            FavoritesPageToggleAdapter(favoritesViewModel),
          );

          return FeedDetailPage(viewModel: detailViewModel);
        },
      ),
    );
  }
}
