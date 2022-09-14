import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

showAlertDialog(BuildContext context, String title, String content) {

  // set up the button
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: content));
      },
        child: SingleChildScrollView(child: Text(content))),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}