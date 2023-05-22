import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:whisper/const/ui_const.dart';
import 'package:whisper/models/app_user.dart';
import 'package:whisper/services/auth_service.dart';
import 'package:whisper/services/chat_services.dart';
import 'package:whisper/services/image_picker_services.dart';

import '../models/message.dart';

class ChatScreen extends StatelessWidget {
  final AppUser receiverUser;

  const ChatScreen({
    Key? key,
    required this.receiverUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(receiverUser.avatarUrl),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              receiverUser.displayName.toString(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: ChatService().getUserMessagesStream(receiverUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasData) {
                      List<Message> messages = [];
                      for (var message in snapshot.data!.docs) {
                        messages.add(Message.fromSnapshot(message));
                      }

                      return Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            bool isSender = messages[index].from ==
                                    AuthService().currentUser!.uid
                                ? true
                                : false;

                            return Column(
                              children: [
                                if (index < messages.length - 1 &&
                                    (messages[index].time.day !=
                                            messages[index + 1].time.day ||
                                        messages[index].time.year !=
                                            messages[index + 1].time.year ||
                                        messages[index].time.month !=
                                            messages[index + 1].time.month ||
                                        messages[index].time.hour !=
                                            messages[index + 1].time.hour ||
                                        messages[index].time.minute !=
                                            messages[index + 1]
                                                .time
                                                .minute)) ...[
                                  DateChip(
                                    date: messages[index].time,
                                    color: const Color(0x558AD3D5),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(
                                      messages[index].time,
                                    ),
                                  ),
                                ],
                                if (messages[index].imageUrl!.isNotEmpty)
                                  BubbleNormalImage(
                                    id: index.toString(),
                                    image: FadeInImage(
                                      image: CachedNetworkImageProvider(
                                        messages[index].imageUrl.toString(),
                                      ),
                                      placeholder: const AssetImage(
                                          'assets/imgs/placeholder.jpg'),
                                    ),
                                    isSender: isSender,
                                    delivered: index == 0 ? true : false,
                                  ),
                                if (messages[index].text.isNotEmpty)
                                  BubbleSpecialThree(
                                    isSender: isSender,
                                    delivered: index == 0 ? true : false,
                                    text: messages[index].text,
                                    color: isSender
                                        ? UIConst.colorSchemeSeed
                                        : Colors.blueGrey,
                                    tail: false,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: UIConst.textChatFontSize,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    } else {
                      return const Text('No message found....');
                    }
                  },
                )
              ],
            ),
          ),
          InputMessage(
            receiverUid: receiverUser.uid,
          ),
        ],
      ),
    );
  }
}

class InputMessage extends StatefulWidget {
  final String receiverUid;
  const InputMessage({
    Key? key,
    required this.receiverUid,
  }) : super(key: key);

  @override
  State<InputMessage> createState() => _InputMessageState();
}

class _InputMessageState extends State<InputMessage> {
  final TextEditingController _controller = TextEditingController();
  bool _isInputEmpty = true;
  bool _isChanged = false;
  bool _isSending = false;
  File? _img;
  late String imageUrl;
  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    return Column(
      children: [
        if (_img != null)
          Image(
            height: 100,
            image: FileImage(_img!),
          ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                _img =
                    await ImagePickerService().pickImage(ImageSource.gallery);
                setState(() {});
              },
              icon: const Icon(
                Icons.image,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 4),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(UIConst.borderRadius),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      if (!_isChanged) {
                        setState(() {
                          _isInputEmpty = false;
                          _isChanged = true;
                        });
                      }
                    } else {
                      if (_isChanged) {
                        setState(() {
                          _isInputEmpty = true;
                          _isChanged = false;
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            _isSending
                ? const CircularProgressIndicator()
                : IconButton(
                    onPressed: _isInputEmpty && _img == null
                        ? null
                        : () async {
                            setState(() {
                              _isSending = true;
                            });
                            await chatService.sendMessage(
                              widget.receiverUid,
                              _controller.text.trim(),
                              _img,
                            );
                            _controller.clear();

                            setState(() {
                              _isChanged = false;
                              _isInputEmpty = true;
                              _img = null;
                              _isSending = false;
                            });
                          },
                    color: UIConst.colorSchemeSeed,
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.send,
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
