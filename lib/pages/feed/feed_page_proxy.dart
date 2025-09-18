import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sketra/pages/detail/feed_detail_page_proxy.dart';
import 'package:sketra/pages/feed/feed_page_grid_cell.dart';

import '../../models/json_wallpaper_service.dart';
import '../shared/content_unavailable_view.dart';
import 'feed_view_model.dart';
import '../../models/remote_wallpaper.dart';

class FeedPageProxy extends StatelessWidget {
  const FeedPageProxy({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/feed-v1.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final service = JsonWallpaperService.name(snapshot.data!);
        return ChangeNotifierProvider(
          create: (_) => FeedViewModel(service)..onLoad(),
          child: FeedPage(title: title),
        );
      },
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _body(viewModel),
    );
  }

  Widget _body(FeedViewModel viewModel) {
    switch (viewModel.viewState) {
      case FeedViewState.loading || FeedViewState.initial:
        return const Center(child: CircularProgressIndicator());
      case FeedViewState.error:
        return ContentUnavailableView.name(
          title: "Failed to load wallpapers",
          description: viewModel.errorMessage,
          onRetry: () => viewModel.onLoad(),
        );
      case FeedViewState.empty:
        return const Center(child: Text("No wallpapers available"));
      case FeedViewState.loaded || FeedViewState.pullToRefreshLoading:
        return RefreshIndicator(
          child: _gridView(viewModel.wallpapers),
          onRefresh: () => viewModel.onPullToRefresh(),
        );
    }
  }

  Widget _errorView(FeedViewModel viewModel) {
    return ContentUnavailableView.name(
      title: "Failed to load wallpapers",
      description: viewModel.errorMessage,
      onRetry: () => viewModel.onLoad(),
    );
  }

  GridView _gridView(List<RemoteWallpaper> wallpapers) {
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
        return _feedPageGridCell(context, wallpapers[index]);
      },
    );
  }

  Widget _feedPageGridCell(BuildContext context, RemoteWallpaper wallpaper) {
    return FeedPageGridCell(
      wallpaper: wallpaper,
      onTap: () => _showFeedDetailPage(context, wallpaper),
    );
  }

  Future<dynamic> _showFeedDetailPage(
    BuildContext context,
    RemoteWallpaper wallpaper,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetailPageProxy(wallpaper.id),
      ),
    );
  }
}
