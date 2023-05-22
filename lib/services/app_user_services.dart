import 'package:whisper/models/app_user.dart';
import 'package:whisper/repositories/user_repository.dart';

class AppUserService {
  final _appUserRepo = UserRepository();

  Stream<AppUser> getUserStreamByUid(String id) {
    return _appUserRepo.getUserByIdStream(id);
  }

  Future<AppUser> getUserByUid(String uid) {
    return _appUserRepo.getUserByUid(uid);
  }
}
