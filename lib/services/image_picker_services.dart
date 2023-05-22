import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<File?> pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) {
      return null;
    }
    File? img = File(image.path);

    return img;
  }
}
