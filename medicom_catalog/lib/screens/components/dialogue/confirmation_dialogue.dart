import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';

Future<void> showConfirmationDialog(
    BuildContext context, String message, VoidCallback onConfirm) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(GluttexConstants.confirmationTxt),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(GluttexConstants.cancelTxt),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(GluttexConstants.confirmTxt),
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
