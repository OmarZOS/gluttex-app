import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';
import 'package:path/path.dart';

class GluttexImage {
  late String filepath;
  late String filename;
  late String entityType;
  late String ownerId;
  late String entityId;

  // GluttexImage();

  setupImage(filepath, filename, entityType, ownerId, entityId) {
    this.filepath = filepath;
    this.filename = filename;
    this.entityType = entityType;
    this.ownerId = ownerId;
    this.entityId = entityId;
  }

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
