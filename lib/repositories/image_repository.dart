import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:whisper/repositories/user_repository.dart';
import 'package:whisper/services/auth_service.dart';
import 'package:whisper/utils/unique_name.dart';

class ImageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateAvatar(File file) async {
    String userUid = AuthService().currentUser!.uid;
    UploadTask task = _storage.ref().child('avatars/$userUid').putFile(file);
    TaskSnapshot taskSnapshot = await task.whenComplete(() => null);

    if (taskSnapshot.state == TaskState.success) {
      final String url = await task.snapshot.ref.getDownloadURL();
      await UserRepository().updateAvatar(url);
    }
  }

  Future<String?> uploadImage(File file, String fromUid, String toUid) async {
    String folderName = UniqueName().combineUniqueStrings(fromUid, toUid);
    var img = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.path}compressed.jpeg',
      quality: 75,
    );
    UploadTask task = _storage
        .ref()
        .child(
            'images/$folderName/${DateTime.now().millisecondsSinceEpoch.toString()}')
        .putFile(
          File(
            img!.path,
          ),
        );

    TaskSnapshot taskSnapshot = await task.whenComplete(() => null);
    if (taskSnapshot.state == TaskState.success) {
      final String url = await task.snapshot.ref.getDownloadURL();
      return url;
    }
    return null;
  }

  Future<void> deleteChatImages(String fromUid, String toUid) async {
    String folderName = UniqueName().combineUniqueStrings(fromUid, toUid);
    var folderRef = _storage.ref().child('images/$folderName');

    var images = await folderRef.listAll();

    for (var img in images.items) {
      await img.delete();
    }
  }
}
