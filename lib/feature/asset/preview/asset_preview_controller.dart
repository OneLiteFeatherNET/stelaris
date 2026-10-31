import 'package:flutter/foundation.dart';

/// The detail level picked in the preview. [automatic] lets the viewer choose by distance.
enum AssetDetail { automatic, reduced }

extension AssetDetailLevel on AssetDetail {
  /// The level index the viewer takes (1 reduced), or null for automatic.
  int? get viewerLevel => switch (this) {
    AssetDetail.automatic => null,
    AssetDetail.reduced => 1,
  };
}

/// Holds what the preview controls ask of the viewer.
///
/// The toolbar changes this state; the viewport listens and applies it to the
/// mounted viewer. Tests read the state back instead of a viewer.
class AssetPreviewController extends ChangeNotifier {
  AssetDetail _detail = AssetDetail.automatic;
  bool _autoRotate = false;
  int _resetRequests = 0;

  AssetDetail get detail => _detail;

  bool get autoRotate => _autoRotate;

  /// Counts the reset requests, so a listener can tell a new request from an old one.
  int get resetRequests => _resetRequests;

  void setDetail(AssetDetail detail) {
    if (detail == _detail) return;
    _detail = detail;
    notifyListeners();
  }

  void setAutoRotate(bool enabled) {
    if (enabled == _autoRotate) return;
    _autoRotate = enabled;
    notifyListeners();
  }

  void resetView() {
    _resetRequests++;
    notifyListeners();
  }
}
