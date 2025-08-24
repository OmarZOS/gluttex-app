// import 'dart:io';
// import 'package:gluttex_core/mediation/StorageService.dart';
// import 'package:path/path.dart';

class GluttexImage<T> {
  late String filepath;
  late String filename;
  late String entityType;
  late String ownerId;
  late String entityId;

  // GluttexImage();

  setupImage({
    required String filepath,
    required String filename,
    required String entityType,
    required String ownerId,
    required String entityId,
  }) {
    this.filepath = filepath;
    this.filename = filename;
    this.entityType = entityType;
    this.ownerId = ownerId;
    this.entityId = entityId;
  }

  Future<T> formData() async {
    throw UnimplementedError();
    // return FormData.fromMap({
    //   'file': await MultipartFile.fromFile(
    //     filepath,
    //     filename: filename,
    //   ),
    // });
  }

  Future<String?> uploadImage() async {
    // StorageService storageService = GluttexLocator.get<StorageService>();
    // return await storageService.insertBinary(
    //     '${GluttexConstants.fsBaseUrl}${GluttexConstants.postImageEndpoint}/$entityType/$ownerId/$entityId/',
    //     await formData());
  }
}
