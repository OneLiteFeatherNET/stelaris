import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// How a model's internal notes are read and written.
///
/// Widgets that take a `ModelNotes` show notes only when given one, so
/// models without notes (sounds, attributes) just leave it out.
class ModelNotes<E extends DataModel> {
  const ModelNotes({required this.read, required this.update});

  /// Returns the model's notes, if any.
  final String? Function(E model) read;

  /// Builds the action that writes new [notes] — `null` when cleared. From
  /// an overview card it saves right away; on a detail page it only stages
  /// them for the page's Save.
  final ReduxAction<AppState> Function(E model, String? notes) update;
}
