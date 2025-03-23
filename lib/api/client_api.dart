import 'package:stelaris/api/model/data_model.dart';

/// A generic client API interface for CRUD operations on data models.
///
/// This abstract class defines the standard operations that should be implemented
/// by any API client that handles [DataModel] objects. It provides a consistent
/// interface for performing Create, Read, Update, and Delete operations.
///
/// Type parameter [T] represents the specific [DataModel] implementation that
/// this client will handle.
///
/// Example usage:
/// ```dart
/// class UserAPI extends ClientAPI<User> {
///   @override
///   Future<User> get() async {
///     // Implementation
///   }
///
///   // Other method implementations
/// }
/// ```
abstract class ClientAPI<T extends DataModel> {

  /// Retrieves a single model instance.
  ///
  /// This method typically fetches a specific model instance based on an identifier
  /// that should be provided by the implementing class.
  ///
  /// Returns a [Future] that completes with the retrieved model instance.
  ///
  /// Throws an exception if the retrieval fails.
  Future<T> get();

  /// Adds a new model to the data store.
  ///
  /// Takes a [model] of type [T] and persists it to the data store.
  ///
  /// Returns a [Future] that completes with the added model, which may contain
  /// additional server-generated fields (like IDs or timestamps).
  ///
  /// Throws an exception if the addition fails.
  Future<T> add(T model);

  /// Retrieves a paginated list of all models.
  ///
  /// This method supports pagination through optional parameters:
  /// - [page]: The page number to retrieve (1-based indexing)
  /// - [items]: The number of items per page
  ///
  /// Returns a [Future] that completes with a list of model instances.
  ///
  /// Example:
  /// ```dart
  /// // Get the first page with 20 items
  /// final firstPage = await api.getAll();
  ///
  /// // Get the second page with 50 items per page
  /// final secondPage = await api.getAll(2, 50);
  /// ```
  Future<List<T>> getAll([int page = 1, int items = 20]);

  /// Updates an existing model in the data store.
  ///
  /// Takes a [model] of type [T] with updated fields and persists the changes
  /// to the data store. The model should contain an identifier to determine
  /// which record to update.
  ///
  /// Returns a [Future] that completes with the updated model, which may contain
  /// additional server-updated fields (like timestamps).
  ///
  /// Throws an exception if the update fails or if the model doesn't exist.
  Future<T> update(T model);

  /// Removes a model from the data store.
  ///
  /// Takes a [model] of type [T] to be removed. The model should contain
  /// an identifier to determine which record to remove.
  ///
  /// Returns a [Future] that completes with the removed model for confirmation.
  ///
  /// Throws an exception if the removal fails or if the model doesn't exist.
  Future<T> remove(T model);
}