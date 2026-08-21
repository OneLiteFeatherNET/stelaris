import 'package:web/web.dart' as web;

void triggerBrowserDownload(String base64Content, String filename) {
  web.HTMLAnchorElement()
    ..setAttribute(
      'href',
      'data:application/octet-stream;base64,$base64Content',
    )
    ..setAttribute('download', filename)
    ..click();
}
