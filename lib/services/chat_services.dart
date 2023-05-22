import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whisper/repositories/chat_reporitory.dart';
import 'package:whisper/repositories/image_repository.dart';
import 'package:whisper/services/auth_service.dart';

import 'app_user_services.dart';

class ChatService {
  final _chatRepo = ChatRepository();
  final _imageRepo = ImageRepository();

  get chatStream => _chatRepo.chatsStream;

  Future<String> getLatestMessage(String receiverUserUid) {
    return _chatRepo.getLatestMessage(receiverUserUid);
  }

  Future<void> sendMessage(String receiverUid, String text,
      [File? imgFile]) async {
    await _chatRepo.addNewMessage(receiverUid, text, imgFile);
  }

  Stream<QuerySnapshot<Object?>> getUserMessagesStream(String receiverUserUid) {
    return _chatRepo.fetchAllMessages(receiverUserUid);
  }

  Future<String> createNewChat(String email) async {
    return await _chatRepo.createNewChat(email);
  }

  Future<void> removeFriends(String friendUid) async {
    await _chatRepo.removeChat(friendUid);
    await _imageRepo.deleteChatImages(
        AuthService().currentUser!.uid, friendUid);
  }

  Future<List> filterChat(List chats, String nameSearch) async {
    final filteredChats = <dynamic>[];
    for (final chat in chats) {
      var name = await AppUserService().getUserByUid(chat);
      if (name.displayName!
          .toLowerCase()
          .contains(nameSearch.trim().toLowerCase())) {
        filteredChats.add(chat);
      }
    }
    return filteredChats;
  }

  Future<bool> isSeenMessage(String receiverUserUid) {
    return _chatRepo.isSeenMessage(receiverUserUid);
  }

  Future<void> updateSeenStatus(String receiverUserUid) async {
    await _chatRepo.updateSeenStatus(receiverUserUid);
  }
}
