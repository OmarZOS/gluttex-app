library gluttex_impl_mediation;

import 'dart:developer' as developer;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/mediation/StorageService.dart';

class StorageServiceImpl implements StorageService {
  final Dio _dio = Dio();

  @override
  Future<String?> delete(String destination, String id) async {
    try {
      final response = await _dio.delete("$destination/$id");
      if (response.statusCode == 200) {
        return GluttexConstants.deleteSuccess;
      } else {
        throw Exception(GluttexConstants.deleteFailure);
      }
    } catch (e) {
      throw Exception(GluttexConstants.serverError);
    }
  }

  @override
  Future<Map<String, dynamic>?> get(String destination, String id) async {
    try {
      final response = await _dio.get('$destination/$id');
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception(GluttexConstants.notFoundError);
      } else {
        throw Exception(GluttexConstants.getFailure);
      }
    } catch (e) {
      throw Exception(GluttexConstants.serverError);
    }
  }

  @override
  Future<dynamic> getAll(String destination) async {
    try {
      final response = await _dio.get(destination);
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception(GluttexConstants.notFoundError);
      } else {
        throw Exception(GluttexConstants.getFailure);
      }
    } catch (e) {
      developer.log(e.toString());
      throw Exception(GluttexConstants.serverError);
    }
  }

  @override
  Future<String?> insert(String destination, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(destination,
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode != 201) {
        throw Exception(GluttexConstants.putFailure);
      }
      return GluttexConstants.putSuccess;
    } catch (e) {
      throw Exception(GluttexConstants.serverError);
    }
  }

  @override
  Future<String?> update(
      String destination, String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("$destination/$id",
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode != 200) {
        throw Exception(GluttexConstants.updateFailure);
      }
      return GluttexConstants.updateSuccess;
    } catch (e) {
      throw Exception(GluttexConstants.serverError);
    }
  }
}
