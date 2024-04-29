import 'package:web/web.dart' as web;

class UriLauncher {

  static final UriLauncher _instance = UriLauncher._internal();

  factory UriLauncher() {
    return _instance;
  }

  UriLauncher._internal();

  void launchURL(String url) async {
    web.window.open(url);
  }

  void launchUrlInTab(String url) async {
    web.window.open(url, "new tab");
  }
}
