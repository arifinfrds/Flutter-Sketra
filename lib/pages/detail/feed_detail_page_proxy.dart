import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sketra/models/download_wallpaper_service.dart';
import 'package:sketra/models/mock_wallpaper_service.dart';
import 'package:sketra/pages/detail/feed_detail_view_model.dart';

import '../shared/async_image.dart';
import '../shared/content_unavailable_view.dart';
import '../shared/confirmation_alert_dialog.dart';

class FeedDetailPageProxy extends StatelessWidget {
  final String wallpaperId;

  const FeedDetailPageProxy(this.wallpaperId, {super.key});

  Future<FeedDetailViewModel> _loadViewModel() async {
    final jsonString = await rootBundle.loadString('assets/mock_feed.json');
    final viewModel = FeedDetailViewModel(
      wallpaperId,
      MockWallpaperService.name(jsonString),
      DownloadWallpaperService(),
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
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FeedDetailViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.pageTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _body(viewModel),
      floatingActionButton: _downloadWallpaperFAB(viewModel),
    );
  }

  Widget _body(FeedDetailViewModel viewModel) {
    _bindToast(viewModel);

    switch (viewModel.viewState) {
      case FeedDetailViewModelViewState.initial:
        return _loadingView();
      case FeedDetailViewModelViewState.loading:
        return _loadingView();
      case FeedDetailViewModelViewState.loaded:
        return AsyncImage(url: viewModel.wallpaper!.url);
      case FeedDetailViewModelViewState.error:
        return _errorView(viewModel);
      case FeedDetailViewModelViewState.imageDownloadLoadingStarted:
        return AsyncImage(url: viewModel.wallpaper!.url);
      case FeedDetailViewModelViewState.imageDownloadedToDevice:
        return AsyncImage(url: viewModel.wallpaper!.url);
      case FeedDetailViewModelViewState.imageDownloadedToDeviceError:
        return AsyncImage(url: viewModel.wallpaper!.url);
    }
  }

  void _bindToast(FeedDetailViewModel viewModel) {
    String? message;

    switch (viewModel.viewState) {
      case FeedDetailViewModelViewState.imageDownloadLoadingStarted:
        message = "Downloading image...";
        break;
      case FeedDetailViewModelViewState.imageDownloadedToDevice:
        message = "Image has been downloaded to your device gallery app";
        break;
      case FeedDetailViewModelViewState.imageDownloadedToDeviceError:
        message =
            "Could not download the image to your device gallery. Please check your permission in system settings, or try again later.";
        break;
      default:
        break;
    }

    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: message!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
        viewModel.resetDownloadState();
      });
    }
  }

  Widget _loadingView() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _errorView(FeedDetailViewModel viewModel) {
    return ContentUnavailableView.name(
      title: "Failed to load wallpaper",
      description: viewModel.errorMessage,
      onRetry: () => {viewModel.onLoad()},
    );
  }

  Widget _downloadWallpaperFAB(FeedDetailViewModel viewModel) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ConfirmationAlertDialog(
            title: "Download wallpaper",
            description:
                "Are you sure you want to download ${viewModel.pageTitle()} image?",
            onPrimaryAction: () {
              viewModel.onDownloadWallpaper();
            },
            primaryActionTitle: 'Yes',
            cancelActionTitle: 'Cancel',
          ),
        );
      },
      child: const Icon(Icons.arrow_circle_down_rounded),
    );
  }
}
