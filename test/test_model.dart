import 'package:stelaris_models/stelaris_models.dart';

/// A simple test model implementing DataModel with an integer internal ID.
class TestModel with DataModel {
  final int internalId;
  final String name;

  TestModel({required this.internalId, required this.name});

  // This is the required implementation for the DataModel mixin.
  @override
  String? get id => internalId.toString();

  // Factory to create from JSON. The JSON from an API likely has an integer ID.
  factory TestModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError('json must be a Map<String, dynamic>');
    }
    return TestModel(
      internalId: json['id'] as int,
      name: json['name'] as String,
    );
  }

  // Method to convert to JSON.
  Map<String, dynamic> toJson() => {
    // We write our internal integer field to the 'id' key in JSON.
    'id': internalId,
    'name': name,
  };

  // Update equals and hashCode for testing comparisons.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TestModel &&
              runtimeType == other.runtimeType &&
              internalId == other.internalId &&
              name == other.name;

  @override
  int get hashCode => internalId.hashCode ^ name.hashCode;
}