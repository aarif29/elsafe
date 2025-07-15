import 'package:flutter/material.dart';

class SnackBarUtils {
  SnackBarUtils._();

  /// Show a success snackbar with a green background and a check circle icon.
  //
  /// [title] is the title of the snackbar.
  /// [message] is the message of the snackbar.
  /// [duration] is the duration of the snackbar. Defaults to 2 seconds.
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showAnimatedSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: Colors.green[700]!,
      icon: Icons.check_circle,
      duration: duration,
    );
  }
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showAnimatedSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: Colors.red[700]!,
      icon: Icons.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showAnimatedSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: Colors.blue[700]!,
      icon: Icons.info,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showAnimatedSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: Colors.orange[700]!,
      icon: Icons.warning,
      duration: duration,
    );
  }

  static void showCustom(
    BuildContext context, {
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showAnimatedSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  static void showSimple(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center, // Center the text
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  static void _showAnimatedSnackBar(
  BuildContext context, {
  required String title,
  required String message,
  required Color backgroundColor,
  required IconData icon,
  required Duration duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          final clampedValue = value.clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, 30 * (1 - clampedValue)),
            child: Opacity(opacity: clampedValue, child: child),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: duration,
      dismissDirection: DismissDirection.down,
    ),
  );
}


  static void showLoading(
    BuildContext context, {
    String message = 'Memproses...',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(days: 1), 
      ),
    );
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}