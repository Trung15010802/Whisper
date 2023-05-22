import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:whisper/const/firestore_const.dart';
import 'package:whisper/repositories/image_repository.dart';
import 'package:whisper/repositories/user_repository.dart';
import 'package:whisper/services/auth_service.dart';

enum Status { success, fail, exist }

class ChatRepository {
  final _chatRef = FirebaseFirestore.instance.collection('chats');
  final user = AuthService().currentUser;

  get chatsStream => _chatRef
      .where(FirestoreConst.chatParticipants, arrayContains: user!.uid)
      .orderBy('Last chat', descending: false)
      .snapshots();

  Future<QuerySnapshot> _getChatQuerySnapshot(String receiverUid) async {
    return await _chatRef.where(FirestoreConst.chatParticipants, whereIn: [
      [user!.uid, receiverUid],
      [receiverUid, user!.uid],
    ]).get();
  }

  Future<bool> isSeenMessage(String receiverUserUid) async {
    final chatQuery = await _getChatQuerySnapshot(receiverUserUid);
    String chatId = chatQuery.docs.first.id;
    final docSnapshot = await _chatRef.doc(chatId).get();
    var data = docSnapshot.data()!['Last chat info'];
    String sender = data['Sender'];
    bool isSeen = data['Seen'];
    if (sender == receiverUserUid) {
      return isSeen;
    } else {
      return true;
    }
  }

  Future<String> createNewChat(String email) async {
    final receiverUser = await UserRepository().getReceiverUser(email);
    if (receiverUser == null) {
      return 'No user found with this email!';
    }

    if (email == AuthService().currentUser!.email) {
      return 'Can\'t create a new chat with your own email!';
    }

    // Kiểm tra xem đoạn chat đã được tạo hay chưa
    final querySnapshot = await _getChatQuerySnapshot(receiverUser.uid);

    if (querySnapshot.docs.isNotEmpty) {
      // Đoạn chat đã tồn tại
      return 'The chat already exists!';
    }
    final documentReference = _chatRef.doc();

    await documentReference.set({
      FirestoreConst.chatParticipants: [user!.uid, receiverUser.uid]
    });

    await _chatRef.doc(documentReference.id).update(
      {
        'Last chat': Timestamp.now(),
      },
    );
    return 'Create new chat successfully!';
  }

  Stream<QuerySnapshot> fetchAllMessages(String receiverUserUid) async* {
    final chatQuery = await _getChatQuerySnapshot(receiverUserUid);

    String chatId = chatQuery.docs.first.id;
    final messages = _chatRef
        .doc(chatId)
        .collection(FirestoreConst.messages)
        .orderBy('time', descending: true)
        .snapshots();
    yield* messages;
  }

  Future<void> addNewMessage(String receiverUid, String text,
      [File? imgFile]) async {
    final chatQuery = await _getChatQuerySnapshot(receiverUid);
    String chatId = chatQuery.docs.first.id;

    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    String? imageUrl;
    if (imgFile != null) {
      imageUrl = (await ImageRepository()
          .uploadImage(imgFile, user!.uid, receiverUid));
    }
    await _chatRef.doc(chatId).collection(FirestoreConst.messages).doc().set({
      'from': user!.uid,
      'to': receiverUid,
      'text': text,
      'time': timestamp,
      'imageUrl': imageUrl ?? '',
    });

    await _chatRef.doc(chatId).update(
      {
        'Last chat': timestamp,
        'Last chat info': {
          'Sender': user!.uid,
          'Seen': false,
        }
      },
    );
  }

  Future<String> getLatestMessage(String receiverUserUid) async {
    final chatQuery = await _getChatQuerySnapshot(receiverUserUid);
    String chatId = chatQuery.docs.first.id;
    final messages = await _chatRef
        .doc(chatId)
        .collection(FirestoreConst.messages)
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    if (messages.docs.isEmpty) {
      return 'Tap to start chatting!';
    }

    return messages.docs.first.get('text');
  }

  Future<void> removeChat(String friendUid) async {
    final chatQuery = await _getChatQuerySnapshot(friendUid);
    String chatId = chatQuery.docs.first.id;

    await _chatRef.doc(chatId).delete();
  }

  Future<void> updateSeenStatus(String receiverUserUid) async {
    final chatQuery = await _getChatQuerySnapshot(receiverUserUid);

    String chatId = chatQuery.docs.first.id;

    var docSnapshot = await _chatRef.doc(chatId).get();
    var data = docSnapshot.data()!['Last chat info'];
    String sender = data['Sender'];
    _chatRef.doc(chatId).update(
      {
        'Last chat info': {
          'Sender': sender,
          'Seen': true,
        }
      },
    );
  }
}
