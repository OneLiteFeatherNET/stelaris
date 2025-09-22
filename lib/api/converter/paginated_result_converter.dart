import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/api/paginated_result.dart';

/// A generic JSON converter for any PaginatedResult`<T>`.
/// - T must extend DataModel. The converter does not require T to have fromJson or toJson methods; instead, these must be provided via function parameters.
/// It requires two functions to be passed to its constructor:
/// - [fromJsonT]: A function that can convert a JSON map into an object of type T.
///   Typically, this will be the `T.fromJson` factory constructor.
/// - [toJsonT]: A function that can convert an object of type T into a JSON map.
///   Typically, this will be a lambda calling the object's `toJson()` method.
class GenericPaginatedResultConverter<T extends DataModel>
    implements JsonConverter<PaginatedResult<T>, Map<String, dynamic>> {
  final T Function(dynamic json) fromJsonT;
  final Map<String, dynamic> Function(T object) toJsonT;

  const GenericPaginatedResultConverter({
    required this.fromJsonT,
    required this.toJsonT,
  });

  @override
  PaginatedResult<T> fromJson(Map<String, dynamic> json) {
    return PaginatedResult<T>.fromJson(json, fromJsonT);
  }

  @override
  Map<String, dynamic> toJson(PaginatedResult<T> object) {
    return object.toJson(toJsonT);
  }
}
