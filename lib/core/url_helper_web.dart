// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation using dart:html directly (bypasses popup blockers issue)
Future<void> openUrl(String url) async {
  html.window.open(url, '_blank');
}
