import 'package:flutter/material.dart';

class ConfirmationAlertDialog extends StatefulWidget {
  final String title;
  final String description;
  final String primaryActionTitle;
  final void Function() onPrimaryAction;
  final String cancelActionTitle;

  const ConfirmationAlertDialog({
    required this.title,
    required this.description,
    required this.primaryActionTitle,
    required this.onPrimaryAction,
    required this.cancelActionTitle,
    super.key,
  });

  @override
  State<ConfirmationAlertDialog> createState() =>
      _ConfirmationAlertDialogState();
}

class _ConfirmationAlertDialogState extends State<ConfirmationAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(widget.description)],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(widget.cancelActionTitle),
        ),
        TextButton(
          onPressed: () {
            widget.onPrimaryAction();
            Navigator.of(context).pop();
          },
          child: Text(widget.primaryActionTitle),
        ),
      ],
    );
  }
}
