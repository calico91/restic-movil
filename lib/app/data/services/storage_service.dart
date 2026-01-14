import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _branchIdKey = 'branch_id';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveBranchId(String branchId) async {
    await _storage.write(key: _branchIdKey, value: branchId);
  }

  Future<String?> getBranchId() async {
    return await _storage.read(key: _branchIdKey);
  }

  Future<void> deleteBranchId() async {
    await _storage.delete(key: _branchIdKey);
  }
}
