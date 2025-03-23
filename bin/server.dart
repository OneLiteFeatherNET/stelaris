import "dart:io";
import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_static/shelf_static.dart";

void main() {
  var handler = createStaticHandler("web", defaultDocument: "index.html");
  io.serve(handler, InternetAddress.anyIPv4, 8080);
  print("Serving at http://localhost:8080");
}