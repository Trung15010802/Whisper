import 'dart:io';

import '../repositories/image_repository.dart';

class StorageService {
  final ImageRepository _imageRepository = ImageRepository();

  saveAvatar(File file) async {
    await _imageRepository.updateAvatar(file);
  }
}
