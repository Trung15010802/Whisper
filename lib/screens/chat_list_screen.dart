import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whisper/const/firestore_const.dart';
import 'package:whisper/const/ui_const.dart';
import 'package:whisper/models/app_user.dart';
import 'package:whisper/screens/chat_screen.dart';
import 'package:whisper/services/app_user_services.dart';
import 'package:whisper/services/auth_service.dart';
import 'package:whisper/services/chat_services.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String searchName = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.chatStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List chatIds = snapshot.data!.docs
              .expand((element) => element.get(FirestoreConst.chatParticipants))
              .where((element) => element != AuthService().currentUser!.uid)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      label: Row(
                        children: [
                          Icon(Icons.search),
                          Text('Search'),
                        ],
                      ),
                    ),
                    onChanged: (value) {
                      searchName = value;
                    },
                    onEditingComplete: () {
                      setState(() {});
                      _searchController.value.text == searchName;
                    }),
              ),
              FutureBuilder(
                future: chatService.filterChat(chatIds, searchName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var chatsData = snapshot.data;

                  return ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: chatsData!.length,
                    itemBuilder: (context, index) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 2, left: 4, right: 4),
                      child: StreamBuilder<AppUser>(
                        stream: AppUserService()
                            .getUserStreamByUid(chatsData[index]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final receiverUser = AppUser(
                            uid: snapshot.data!.uid,
                            displayName: snapshot.data!.displayName,
                            email: snapshot.data!.email,
                            avatarUrl: snapshot.data!.avatarUrl,
                          );

                          return ListTile(
                            tileColor: Colors.lightGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(UIConst.borderRadius),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverUser: receiverUser,
                                  ),
                                ),
                              );
                              chatService.updateSeenStatus(receiverUser.uid);
                            },
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    receiverUser.avatarUrl,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(receiverUser.displayName.toString()),
                              ],
                            ),
                            subtitle: FutureBuilder<String>(
                              future: chatService
                                  .getLatestMessage(snapshot.data!.uid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                }
                                String latestMessage = snapshot.data.toString();
                                if (latestMessage.isEmpty) {
                                  latestMessage = '[Image]';
                                }
                                return Text(
                                  latestMessage,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: UIConst.textChatFontSize,
                                  ),
                                );
                              },
                            ),
                            trailing: FutureBuilder<bool>(
                              future: chatService.isSeenMessage(
                                receiverUser.uid,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const SizedBox.shrink();
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                }
                                bool isSeen = snapshot.data!;
                                return isSeen
                                    ? const SizedBox.shrink()
                                    : Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 0, 255, 8),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text("An error has occured!"));
        }
        return const Center(
            child: Text("The chat is empty. Let's talk to someone"));
      },
    );
  }
}
