/// The [DataModel] is a mixin class which is used as a marker class to indicate that a class is a data model.
/// This is usefully to limit [List] and other storage options to only contain data models.
mixin DataModel {
  /// Returns the id from a model which is represented by a [String]
  String? get id;
}
