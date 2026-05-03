import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Singleton logger aplikasi.
/// - Debug/development: semua level ditampilkan di console.
/// - Release/production: semua log dimatikan (Level.off).
final appLog = Logger(
  level: kReleaseMode ? Level.off : Level.debug,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: false,
  ),
);
