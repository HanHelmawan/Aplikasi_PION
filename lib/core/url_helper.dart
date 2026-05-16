/// Conditional export — selects the correct implementation at compile time.
/// On web  → url_helper_web.dart  (uses dart:html)
/// On other → url_helper_mobile.dart (uses url_launcher)
export 'url_helper_mobile.dart'
    if (dart.library.html) 'url_helper_web.dart';
