import 'package:flutter/material.dart';

class StartNewGameDialog {
  const StartNewGameDialog._();
  static Future show(
    BuildContext context, {
    VoidCallback? onCancelPressed,
    VoidCallback? onOkPressed,
  }) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Start New Game'),
          content:
              const Text('Starting a new game will erase your current game'),
          actions: [
            _adaptiveAction(
              context: context,
              onPressed: () {
                onCancelPressed?.call();
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Cancel'),
            ),
            _adaptiveAction(
              context: context,
              onPressed: () {
                onOkPressed?.call();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Widget _adaptiveAction({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return TextButton(onPressed: onPressed, child: child);
  }
}
