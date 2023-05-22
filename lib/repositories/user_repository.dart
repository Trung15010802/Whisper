import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:whisper/services/auth_service.dart';
import '../models/app_user.dart';

class UserRepository {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  void addNewUser(AppUser user) {
    _usersRef.doc(user.uid).set({
      'displayName': user.displayName,
      'uid': user.uid,
      'email': user.email,
      'avatar': user.avatarUrl
    });
  }

  Future<void> updateAvatar(String avatarUrl) async {
    await _usersRef.doc(AuthService().currentUser!.uid).update({
      'avatar': avatarUrl,
    });
  }

  Stream<AppUser> getUserByIdStream(String id) {
    return _usersRef.doc(id).snapshots().map(
          (snapshot) => AppUser(
              uid: id,
              displayName: snapshot['displayName'],
              email: snapshot['email'],
              avatarUrl: snapshot['avatar'] // Thêm đoạn code này
              ),
        );
  }

  Future<AppUser?> getReceiverUser(String email) async {
    var query = await checkEmailExists(email);
    if (query != null) {
      var doc = query.docs.first;
      String userUid = doc.get('uid');
      String displayName = doc.get('displayName');

      return AppUser(uid: userUid, displayName: displayName, email: email);
    }
    return null;
  }

  Future<AppUser> getUserByUid(String uid) async {
    var userSnapshot = await _usersRef.doc(uid).get();
    return AppUser(
      uid: uid,
      displayName: userSnapshot['displayName'],
      email: userSnapshot['email'],
      avatarUrl: userSnapshot['avatar'],
    );
  }

  Future<QuerySnapshot?> checkEmailExists(String email) async {
    QuerySnapshot query =
        await _usersRef.where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      // Email exists in users collection
      return query;
    } else {
      // Email does not exist in users collection
      return null;
    }
  }
}
