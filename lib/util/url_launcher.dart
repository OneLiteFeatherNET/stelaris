import 'package:url_launcher/url_launcher.dart';

/// A utility class for launching URLs in a cross-platform manner.
///
/// This class provides methods to open URLs, abstracting away platform-specific
/// implementations by using the `url_launcher` package.
///
/// Usage:
/// ```dart
/// // Open URL (platform handles whether it's in a new tab/window or app)
/// UriLauncher.launchURL('https://example.com');
/// ```
final class UriLauncher {

  /// Private constructor to prevent instantiation.
  UriLauncher._();

  /// Opens a URL using the platform's default application.
  ///
  /// On web, this typically opens in a new tab/window.
  /// On mobile, this might open a browser app.
  ///
  /// Parameters:
  ///   [url] - The URL string to launch. Must be a valid URI.
  /// Returns `true` if the URL was successfully launched, `false` otherwise.
  static Future<bool> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    } else {
      // Log an error or show a user-friendly message
      // For now, we'll just return false.
      return false;
    }
  }
}
