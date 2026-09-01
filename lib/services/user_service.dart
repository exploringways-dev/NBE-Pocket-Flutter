import '../models/user_profile.dart';
import 'api_client.dart';
import 'api_exception.dart';

class UserService {
  UserService({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  Future<UserProfile> getProfile() async {
    final data = await _api.get('/api/Users/profile');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('The server returned an invalid profile.');
    }
    return UserProfile.fromJson(data);
  }
}
