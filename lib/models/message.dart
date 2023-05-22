import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String from;
  String to;
  String text;
  DateTime time;
  String? imageUrl;
  Message({
    required this.from,
    required this.to,
    required this.text,
    required this.time,
    this.imageUrl,
  });

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Message(
      from: data['from'],
      to: data['to'],
      text: data['text'],
      imageUrl: data['imageUrl'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
    );
  }
}
