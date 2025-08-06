import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';
import 'package:path/path.dart';

class GluttexImage {
  final String filepath;
  final String filename;
  final String entityType;
  final String ownerId;
  final String entityId;

  GluttexImage(
      {required this.filepath,
      required this.filename,
      required this.entityType,
      required this.ownerId,
      required this.entityId});

  Future<FormData> formData() async {
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filepath,
        filename: filename,
      ),
    });
  }

  Future<String?> uploadImage() async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    return await storageService.insertBinary(
        '${GluttexConstants.fsBaseUrl}${GluttexConstants.postImageEndpoint}/$entityType/$ownerId/$entityId/',
        await formData());
  }
}
