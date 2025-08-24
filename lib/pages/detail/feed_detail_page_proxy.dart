import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sketra/models/mock_wallpaper_repository.dart';
import 'package:sketra/pages/detail/feed_detail_view_model.dart';

import '../shared/async_image.dart';
import '../shared/content_unavailable_view.dart';
import '../shared/download_wallpaper_alert_dialog.dart';

class FeedDetailPageProxy extends StatelessWidget {
  final String wallpaperId;

  const FeedDetailPageProxy(this.wallpaperId, {super.key});

  Future<FeedDetailViewModel> _loadViewModel() async {
    final jsonString = await rootBundle.loadString('assets/mock_feed.json');
    final viewModel = FeedDetailViewModel(
      wallpaperId,
      MockWallpaperRepository.name(jsonString),
    );
    await viewModel.onLoad();
    return viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FeedDetailViewModel>(
      future: _loadViewModel(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ChangeNotifierProvider<FeedDetailViewModel>.value(
          value: snapshot.data!,
          child: const FeedDetailPage(),
        );
      },
    );
  }
}

class FeedDetailPage extends StatefulWidget {
  const FeedDetailPage({super.key});

  @override
  State<FeedDetailPage> createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  late final FeedDetailViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FeedDetailViewModel>(context);
    this._viewModel = viewModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.pageTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _body(viewModel),
      floatingActionButton: _downloadWallpaperFAB(),
    );
  }

  Widget _body(FeedDetailViewModel viewModel) {
    switch (viewModel.viewState) {
      case FeedDetailViewModelViewState.initial:
        return _loadingView();
      case FeedDetailViewModelViewState.loading:
        return _loadingView();
      case FeedDetailViewModelViewState.loaded:
        return AsyncImage(url: viewModel.wallpaper!.url);
      case FeedDetailViewModelViewState.error:
        return _errorView();
    }
  }

  Widget _loadingView() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _errorView() {
    return ContentUnavailableView.name(
      title: "Failed to load wallpaper",
      description: _viewModel.errorMessage,
      onRetry: () => {_viewModel.onLoad()},
    );
  }

  Widget _downloadWallpaperFAB() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => DownloadWallpaperAlertDialog(
            wallpaperTitle: _viewModel.pageTitle(),
            onPrimaryAction: () {},
          ),
        );
      },
      child: const Icon(Icons.arrow_circle_down_rounded),
    );
  }
}
