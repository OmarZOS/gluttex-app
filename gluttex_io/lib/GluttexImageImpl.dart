import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:locator/locator.dart';
import 'package:path/path.dart';

class GluttexImageImpl extends GluttexImage<FormData> {
  GluttexImageImpl();

  @override
  Future<FormData> formData() async {
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filepath,
        filename: filename,
      ),
    });
  }

  @override
  Future<String?> uploadImage() async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    log("uploading");
    dynamic result = await storageService.insertBinary(
        '${GluttexConstants.fsBaseUrl}${GluttexConstants.postImageEndpoint}/$entityType/$ownerId/$entityId/',
        await formData());

    return result['path'].toString().replaceFirst("files/", "");
  }
}
