import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sketra/pages/detail/feed_detail_page_proxy.dart';
import 'package:sketra/pages/feed/feed_page_grid_cell.dart';

import '../../models/json_wallpaper_service.dart';
import '../shared/content_unavailable_view.dart';
import 'feed_view_model.dart';
import '../../models/wallpaper.dart';

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

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.title});

  final String title;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final FeedViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    final jsonString = await rootBundle.loadString('assets/feed-v1.json');
    final service = JsonWallpaperService.name(jsonString);

    viewModel = FeedViewModel(service);
    viewModel.addListener(_onViewModelChanged);
    await viewModel.onLoad();

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.removeListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _body(),
    );
  }

  Widget _body() {
    switch (viewModel.viewState) {
      case FeedViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case FeedViewState.error:
        return _errorView();
      case FeedViewState.empty:
        return const Center(child: Text("No wallpapers available"));
      case FeedViewState.loaded || FeedViewState.pullToRefreshLoading:
        return RefreshIndicator(
          child: _gridView(viewModel.wallpapers),
          onRefresh: () {
            return viewModel.onPullToRefresh();
          },
        );
      default:
        return const SizedBox();
    }
  }

  Widget _errorView() {
    return ContentUnavailableView.name(
      title: "Failed to load wallpapers",
      description: viewModel.errorMessage,
      onRetry: () => viewModel.onLoad(),
    );
  }

  GridView _gridView(List<Wallpaper> wallpapers) {
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
        return _feedPageGridCell(wallpapers[index]);
      },
    );
  }

  Widget _feedPageGridCell(Wallpaper wallpaper) {
    return FeedPageGridCell(
      wallpaper: wallpaper,
      onTap: () => _showFeedDetailPage(context, wallpaper),
    );
  }

  Future<dynamic> _showFeedDetailPage(
    BuildContext context,
    Wallpaper wallpaper,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetailPageProxy(wallpaper.id),
      ),
    );
  }
}
