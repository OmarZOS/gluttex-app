abstract class StorageService {
  Future<dynamic> getAll(String destination) async {
    return null;
  }

  Future<String?> insert(String destination, Map<String, dynamic> data) async {
    return null;
  }

  Future<Map<String, dynamic>?> get(String destination, String id) async {
    return null;
  }

  Future<String?> delete(String destination, String id) async {
    return null;
  }

  Future<String?> update(
      String destination, String id, Map<String, dynamic> data) async {
    return null;
  }
}
