import 'package:flutter/material.dart';

class DownloadWallpaperAlertDialog extends StatefulWidget {
  final String wallpaperTitle;
  final void Function() onPrimaryAction;

  const DownloadWallpaperAlertDialog({
    required this.wallpaperTitle,
    required this.onPrimaryAction,
    super.key,
  });

  @override
  State<DownloadWallpaperAlertDialog> createState() =>
      _DownloadWallpaperAlertDialogState();
}

class _DownloadWallpaperAlertDialogState
    extends State<DownloadWallpaperAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Download a wallpaper"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Are you sure you want to download ${widget.wallpaperTitle} image?",
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onPrimaryAction();
            Navigator.of(context).pop();
          },
          child: Text('Download'),
        ),
      ],
    );
  }
}
