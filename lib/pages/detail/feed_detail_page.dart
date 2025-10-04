import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sketra/pages/detail/feed_detail_view_model.dart';
import '../../data/networking/set_wallpaper_type.dart';
import '../shared/async_image.dart';
import '../shared/content_unavailable_view.dart';
import '../shared/confirmation_alert_dialog.dart';

typedef ViewState = FeedDetailViewModelViewState;

class FeedDetailPage extends StatelessWidget {
  final FeedDetailViewModel viewModel;

  const FeedDetailPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    viewModel.onLoad();
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: _FeedDetailPageContent(),
    );
  }
}

class _FeedDetailPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FeedDetailViewModel>(context);
    bool isLoading =
        viewModel.viewState == ViewState.loading ||
        viewModel.viewState == ViewState.imageDownloadLoadingStarted;

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.pageTitle()),
        actions: isLoading
            ? []
            : [
                _favoriteFloatingActionButton(viewModel),
                _popupMenuButton(context, viewModel),
              ],
      ),
      body: _body(context, viewModel),
      floatingActionButton: _floatingActionButton(context, viewModel),
    );
  }

  Widget? _floatingActionButton(
    BuildContext context,
    FeedDetailViewModel viewModel,
  ) {
    return Platform.isAndroid
        ? _setAsWallpaperFAB(context, viewModel)
        : _downloadWallpaperFAB(context, viewModel);
  }

  Widget _favoriteFloatingActionButton(FeedDetailViewModel viewModel) {
    bool isLoading = viewModel.viewState == ViewState.favoriteActionLoading;
    return TextButton(
      onPressed: () {
        if (isLoading) {
          return;
        } else {
          viewModel.toggleFavorite();
        }
      },
      child: isLoading
          ? SizedBox(width: 16, height: 16, child: _loadingView())
          : viewModel.isFavorite
          ? const Icon(Icons.favorite)
          : const Icon(Icons.favorite_border_outlined),
    );
  }

  Widget _popupMenuButton(BuildContext context, FeedDetailViewModel viewModel) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'save':
            viewModel.onDownloadWallpaper();
          case 'set_wallpaper':
            if (Platform.isAndroid) {
              _showSetAsWallpaperConfirmationAlertDialog(context, viewModel);
            } else {
              _showSetWallpaperAlertBottomSheetForIOS(context, viewModel);
            }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'save',
          child: Text('Save to Device Gallery'),
        ),
        PopupMenuItem<String>(
          value: 'set_wallpaper',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Set as wallpaper')],
          ),
        ),
      ],
    );
  }

  void _showSetWallpaperAlertBottomSheetForAndroid(
    BuildContext context,
    FeedDetailViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              title: Text('Set as Wallpaper on lock screen'),
              onTap: () {
                _setAsWallpaper(
                  context,
                  viewModel,
                  SetWallpaperType.lockScreen,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Set as Wallpaper on home screen'),
              onTap: () {
                _setAsWallpaper(
                  context,
                  viewModel,
                  SetWallpaperType.homeScreen,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Set as Wallpaper on home and lock screens'),
              onTap: () {
                _setAsWallpaper(
                  context,
                  viewModel,
                  SetWallpaperType.bothScreens,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _setAsWallpaper(
    BuildContext context,
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

  void _showSetWallpaperAlertBottomSheetForIOS(
    BuildContext context,
    FeedDetailViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Set Wallpaper on iOS",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Due to iOS restrictions, you cannot set the wallpaper directly from the app. "
                  "Please follow these steps:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text("1. Download the image to your Photos app."),
                const SizedBox(height: 8),
                const Text("2. Open the Photos app and select the image."),
                const SizedBox(height: 8),
                const Text(
                  "3. Tap the share button and select 'Use as Wallpaper'.",
                ),
                const SizedBox(height: 42),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, FeedDetailViewModel viewModel) {
    _bindToast(viewModel);

    switch (viewModel.viewState) {
      case ViewState.initial || ViewState.loading:
        return _loadingView();
      case ViewState.loaded:
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: AsyncImage(url: viewModel.wallpaper!.url),
          ),
        );
      case ViewState.error:
        return _errorView(viewModel);
      case ViewState.imageDownloadLoadingStarted ||
          ViewState.imageDownloadedToDevice ||
          ViewState.imageDownloadedToDeviceError ||
          ViewState.settingImageAsWallpaperSuccessfully ||
          ViewState.settingImageAsWallpaperError ||
          ViewState.favoriteActionLoading ||
          ViewState.favoriteActionLoadingFinished ||
          ViewState.favoriteUnfavoriteOperationError:
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: AsyncImage(url: viewModel.wallpaper!.url),
          ),
        );
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

  Widget _downloadWallpaperFAB(
    BuildContext context,
    FeedDetailViewModel viewModel,
  ) {
    bool isLoading =
        viewModel.viewState == ViewState.loading ||
        viewModel.viewState == ViewState.imageDownloadLoadingStarted;

    return FloatingActionButton(
      onPressed: () {
        if (isLoading) {
          return;
        } else {
          _showDownloadWallpaperConfirmationAlertDialog(context, viewModel);
        }
      },
      child: isLoading
          ? SizedBox(width: 24, height: 24, child: _loadingView())
          : const Icon(Icons.arrow_circle_down_rounded),
    );
  }

  void _showDownloadWallpaperConfirmationAlertDialog(
    BuildContext context,
    FeedDetailViewModel viewModel,
  ) {
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

  Widget _setAsWallpaperFAB(
    BuildContext context,
    FeedDetailViewModel viewModel,
  ) {
    bool isLoading =
        viewModel.viewState == ViewState.loading ||
        viewModel.viewState == ViewState.imageDownloadLoadingStarted;

    return FloatingActionButton(
      onPressed: () {
        if (isLoading) {
          return;
        } else {
          _showSetAsWallpaperConfirmationAlertDialog(context, viewModel);
        }
      },
      child: isLoading
          ? SizedBox(width: 24, height: 24, child: _loadingView())
          : const Icon(Icons.wallpaper),
    );
  }

  void _showSetAsWallpaperConfirmationAlertDialog(
    BuildContext context,
    FeedDetailViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (alertDialogContext) => ConfirmationAlertDialog(
        title: "Set as wallpaper",
        description:
            "Are you sure you want to set ${viewModel.pageTitle()} image as wallpaper?",
        onPrimaryAction: () {
          Future.delayed(const Duration(milliseconds: 300), () {
            _showSetWallpaperAlertBottomSheetForAndroid(context, viewModel);
          });
        },
        primaryActionTitle: 'Yes',
        cancelActionTitle: 'Cancel',
      ),
    );
  }
}
