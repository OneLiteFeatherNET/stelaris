import 'package:web/web.dart' as web;

/// A utility class for launching URLs in the browser.
///
/// This class provides methods to open URLs in the current browser window
/// or in a new browser tab. It uses the web package to interact with the
/// browser's window API.
///
/// Usage:
/// ```dart
/// // Open URL in the current window
/// UriLauncher.launchURL('https://example.com');
/// 
/// // Open URL in a new tab
/// UriLauncher.launchUrlInTab('https://example.com');
/// ```
final class UriLauncher {

  /// Private constructor to prevent instantiation.
  /// 
  /// This class is not meant to be instantiated as all methods are static.
  UriLauncher._();

  /// Opens a URL in the current browser window.
  /// 
  /// This method uses the browser's window.open() function to navigate
  /// to the specified URL in the current window.
  /// 
  /// Parameters:
  ///   [url] - The URL to open. Should be a valid URL string.
  static void launchURL(String url) async {
    web.window.open(url);
  }

  /// Opens a URL in a new browser tab.
  /// 
  /// This method uses the browser's window.open() function with the 'new tab'
  /// target to open the specified URL in a new browser tab.
  /// 
  /// Parameters:
  ///   [url] - The URL to open. Should be a valid URL string.
  static void launchUrlInTab(String url) async {
    web.window.open(url, 'new tab');
  }
}
