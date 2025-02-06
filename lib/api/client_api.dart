import 'package:stelaris/api/model/data_model.dart';

/// The class represents each function which a implementation fo the ClientAPI should have.
abstract class ClientAPI<T extends DataModel> {

  Future<T> get();

  Future<T> add(T model);

  Future<List<T>> getAll();

  Future<T> update(T model);

  Future<T> remove(T model);
}