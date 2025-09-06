import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sketra/models/download_wallpaper_service.dart';
import 'package:sketra/models/mock_wallpaper_service.dart';
import 'package:sketra/models/set_wallpaper_type.dart';
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
        actions: [_popupMenuButton(viewModel)],
      ),
      body: _body(viewModel),
      floatingActionButton: _downloadWallpaperFAB(viewModel),
    );
  }

  Widget _popupMenuButton(FeedDetailViewModel viewModel) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'save':
            viewModel.onDownloadWallpaper();
          case 'set_wallpaper_both':
            _setAsWallpaper(viewModel, SetWallpaperType.bothScreens);
          case 'set_wallpaper_lockscreen':
            _setAsWallpaper(viewModel, SetWallpaperType.lockScreen);
          case 'set_wallpaper_home':
            _setAsWallpaper(viewModel, SetWallpaperType.homeScreen);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'save',
          child: Text('Save to Device Gallery'),
        ),
        const PopupMenuItem<String>(
          value: 'set_wallpaper_both',
          child: Text('Set as Wallpaper on home and lock screens'),
        ),
        const PopupMenuItem<String>(
          value: 'set_wallpaper_lockscreen',
          child: Text('Set as Wallpaper on lock screen'),
        ),
        const PopupMenuItem<String>(
          value: 'set_wallpaper_home screen',
          child: Text('Set as Wallpaper on home screen'),
        ),
      ],
    );
  }

  void _setAsWallpaper(
    FeedDetailViewModel viewModel,
    SetWallpaperType setWallpaperType,
  ) {
    if (Platform.isAndroid) {
      viewModel.setAsWallpaper(setWallpaperType);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Setting wallpaper is only available on Android"),
        ),
      );
    }
  }

  Widget _body(FeedDetailViewModel viewModel) {
    _bindToast(viewModel);

    switch (viewModel.viewState) {
      case FeedDetailViewModelViewState.initial ||
          FeedDetailViewModelViewState.loading:
        return _loadingView();
      case FeedDetailViewModelViewState.loaded:
        return AsyncImage(url: viewModel.wallpaper!.url);
      case FeedDetailViewModelViewState.error:
        return _errorView(viewModel);
      case FeedDetailViewModelViewState.imageDownloadLoadingStarted ||
          FeedDetailViewModelViewState.imageDownloadedToDevice ||
          FeedDetailViewModelViewState.imageDownloadedToDeviceError ||
          FeedDetailViewModelViewState.settingImageAsWallpaperSuccessfully ||
          FeedDetailViewModelViewState.settingImageAsWallpaperError:
        return AsyncImage(url: viewModel.wallpaper!.url);
    }
  }

  void _bindToast(FeedDetailViewModel viewModel) {
    String? message = viewModel.getToastMessage();

    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: message,
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
