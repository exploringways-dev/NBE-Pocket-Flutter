import '../models/category.dart';
import 'api_client.dart';
import 'api_exception.dart';

class CategoryService {
  CategoryService({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  Future<List<ApiCategory>> getAll() async {
    final data = await _api.get('/Categories');
    if (data is! List) {
      throw const ApiException('The server returned invalid categories.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(ApiCategory.fromJson)
        .toList();
  }

  Future<ApiCategory> create(String name) async {
    final data = await _api.post('/Categories', body: {'catName': name});
    if (data is! Map<String, dynamic>) {
      throw const ApiException('The server returned an invalid category.');
    }
    return ApiCategory.fromJson(data);
  }

  Future<void> update(int id, String name) async {
    await _api.put('/Categories/$id', body: {'catName': name});
  }

  Future<void> delete(int id) async {
    await _api.delete('/Categories/$id');
  }
}
