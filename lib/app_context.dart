import 'dart:math';

import 'package:flutter/foundation.dart';

class AppClientContext {
  AppClientContext({
    required this.userId,
    required this.sessionId,
    required this.appVersion,
    required this.platform,
  });

  final String userId;
  final String sessionId;
  final String appVersion;
  final String platform;
}

String currentPlatform() {
  if (kIsWeb) return 'web';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'android';
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.windows:
      return 'windows';
    case TargetPlatform.macOS:
      return 'macos';
    case TargetPlatform.linux:
      return 'linux';
    case TargetPlatform.fuchsia:
      return 'fuchsia';
  }
}

String generateSessionId() => _randomId('sess');

String generateRequestId() => _randomId('req');

String _randomId(String prefix) {
  final rand = Random().nextInt(1 << 30);
  final ts = DateTime.now().microsecondsSinceEpoch;
  return '$prefix-$ts-$rand';
}
