import 'dart:typed_data';

/// [bytes] as a [Uint8List], copied only when it isn't one already.
///
/// A download comes as a `List<int>` that usually is a [Uint8List]; using it
/// as it is keeps one copy of a file in memory instead of one per user.
Uint8List asUint8List(List<int> bytes) =>
    bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
