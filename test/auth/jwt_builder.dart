import 'dart:convert';

/// Builds an unsigned JSON Web Token around [claims].
///
/// Tests need a token-shaped string to exercise decoding, and a literal one
/// checked into the repository is a high-entropy blob that every secret scanner
/// flags - correctly, since it cannot tell a real credential from a prop.
/// Assembling it here keeps the shape and leaves nothing to find.
///
/// Unsigned on purpose: nothing in this application verifies an access token's
/// signature, and a test that supplied one would imply otherwise.
String unsignedJwt(Map<String, dynamic> claims) {
  String segment(Map<String, dynamic> part) =>
      base64Url.encode(utf8.encode(jsonEncode(part))).replaceAll('=', '');

  final String header = segment(const {'alg': 'none', 'typ': 'JWT'});
  return '$header.${segment(claims)}.';
}
