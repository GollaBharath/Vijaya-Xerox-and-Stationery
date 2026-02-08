import 'package:flutter/material.dart';

Future<bool> showExitConfirmation(
  BuildContext context, {
  String title = 'Exit Admin App',
  String message = 'Do you want to close the admin app?',
  String stayLabel = 'Stay',
  String exitLabel = 'Exit',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(stayLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(exitLabel),
        ),
      ],
    ),
  );

  return result ?? false;
}

Future<bool> handleBackNavigation(
  BuildContext context, {
  String title = 'Exit Admin App',
  String message = 'Do you want to close the admin app?',
  String stayLabel = 'Stay',
  String exitLabel = 'Exit',
}) async {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
    return false;
  }

  return showExitConfirmation(
    context,
    title: title,
    message: message,
    stayLabel: stayLabel,
    exitLabel: exitLabel,
  );
}

class BackNavigationGuard extends StatelessWidget {
  final Widget child;
  final String title;
  final String message;
  final String stayLabel;
  final String exitLabel;

  const BackNavigationGuard({
    super.key,
    required this.child,
    this.title = 'Exit Admin App',
    this.message = 'Do you want to close the admin app?',
    this.stayLabel = 'Stay',
    this.exitLabel = 'Exit',
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => handleBackNavigation(
        context,
        title: title,
        message: message,
        stayLabel: stayLabel,
        exitLabel: exitLabel,
      ),
      child: child,
    );
  }
}
