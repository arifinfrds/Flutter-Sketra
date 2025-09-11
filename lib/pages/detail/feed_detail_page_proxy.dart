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

typedef ViewState = FeedDetailViewModelViewState;

class FeedDetailPageProxy extends StatefulWidget {
  final String wallpaperId;

  const FeedDetailPageProxy(this.wallpaperId, {super.key});

  @override
  State<FeedDetailPageProxy> createState() => _FeedDetailPageProxyState();
}

class _FeedDetailPageProxyState extends State<FeedDetailPageProxy> {
  late Future<FeedDetailViewModel> _future;

  @override
  void initState() {
    super.initState();

    _future = _loadViewModel();
  }

  Future<FeedDetailViewModel> _loadViewModel() async {
    final jsonString = await rootBundle.loadString('assets/mock_feed.json');
    final viewModel = FeedDetailViewModel(
      widget.wallpaperId,
      MockWallpaperService.name(jsonString),
      DownloadWallpaperService(),
    );
    await viewModel.onLoad();
    return viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FeedDetailViewModel>(
      future: _future, // ✅ cached future
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
    bool isLoading =
        viewModel.viewState == ViewState.loading ||
        viewModel.viewState == ViewState.imageDownloadLoadingStarted;

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.pageTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: isLoading ? [] : [_popupMenuButton(viewModel)],
      ),
      body: _body(viewModel),
      floatingActionButton: Platform.isAndroid
          ? _setAsWallpaperFAB(viewModel)
          : _downloadWallpaperFAB(viewModel),
    );
  }

  Widget _popupMenuButton(FeedDetailViewModel viewModel) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'save':
            viewModel.onDownloadWallpaper();
          case 'set_wallpaper':
            _showSetWallpaperAlertBottomSheet(viewModel);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'save',
          child: Text('Save to Device Gallery'),
        ),
        const PopupMenuItem<String>(
          value: 'set_wallpaper',
          child: Text('Set as wallpaper'),
        ),
      ],
    );
  }

  void _showSetWallpaperAlertBottomSheet(FeedDetailViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              title: Text('Set as Wallpaper on lock screen'),
              onTap: () {
                _setAsWallpaper(viewModel, SetWallpaperType.lockScreen);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Set as Wallpaper on home screen'),
              onTap: () {
                _setAsWallpaper(viewModel, SetWallpaperType.homeScreen);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Set as Wallpaper on home and lock screens'),
              onTap: () {
                _setAsWallpaper(viewModel, SetWallpaperType.bothScreens);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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
      case ViewState.initial || ViewState.loading:
        return _loadingView();
      case ViewState.loaded:
        return AsyncImage(url: viewModel.wallpaper!.url);
      case ViewState.error:
        return _errorView(viewModel);
      case ViewState.imageDownloadLoadingStarted ||
          ViewState.imageDownloadedToDevice ||
          ViewState.imageDownloadedToDeviceError ||
          ViewState.settingImageAsWallpaperSuccessfully ||
          ViewState.settingImageAsWallpaperError:
        return AsyncImage(url: viewModel.wallpaper!.url);
    }
  }

  void _bindToast(FeedDetailViewModel viewModel) {
    String? message = viewModel.getToastMessage();

    if (message != null || message != "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: message!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
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
    bool isLoading =
        viewModel.viewState == ViewState.loading ||
        viewModel.viewState == ViewState.imageDownloadLoadingStarted;

    return FloatingActionButton(
      onPressed: () {
        if (isLoading) {
          return;
        } else {
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
        }
      },
      child: isLoading
          ? SizedBox(width: 24, height: 24, child: _loadingView())
          : const Icon(Icons.arrow_circle_down_rounded),
    );
  }

  Widget _setAsWallpaperFAB(FeedDetailViewModel viewModel) {
    bool isLoading =
        viewModel.viewState == ViewState.loading ||
        viewModel.viewState == ViewState.imageDownloadLoadingStarted;

    return FloatingActionButton(
      onPressed: () {
        if (isLoading) {
          return;
        } else {
          showDialog(
            context: context,
            builder: (alertDialogContext) => ConfirmationAlertDialog(
              title: "Set as wallpaper",
              description:
                  "Are you sure you want to set ${viewModel.pageTitle()} image as wallpaper?",
              onPrimaryAction: () {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _showSetWallpaperAlertBottomSheet(viewModel);
                });
              },
              primaryActionTitle: 'Yes',
              cancelActionTitle: 'Cancel',
            ),
          );
        }
      },
      child: isLoading
          ? SizedBox(width: 24, height: 24, child: _loadingView())
          : const Icon(Icons.wallpaper),
    );
  }
}
