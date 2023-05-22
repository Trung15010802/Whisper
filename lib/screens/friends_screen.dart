import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whisper/const/ui_const.dart';
import 'package:whisper/models/app_user.dart';
import 'package:whisper/services/app_user_services.dart';
import 'package:whisper/services/chat_services.dart';

import '../const/firestore_const.dart';
import '../services/auth_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String searchName = '';
  final _searchController = TextEditingController();
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
        List chatFriends = snapshot.data!.docs
            .expand((element) => element.get(FirestoreConst.chatParticipants))
            .where((element) => element != AuthService().currentUser!.uid)
            .toList();

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
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
                      _searchController.text = searchName;
                    }),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: chatFriends.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<AppUser>(
                      future: AppUserService().getUserByUid(chatFriends[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        var friendAppUser = snapshot.data;

                        if (searchName.isNotEmpty &&
                            !friendAppUser!.displayName!
                                .toLowerCase()
                                .contains(searchName.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    friendAppUser!.avatarUrl),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  friendAppUser.displayName.toString(),
                                  style: TextStyle(
                                    fontSize: UIConst.bodyLargeFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          subtitle: Text(
                            friendAppUser.email.toString(),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  actionsAlignment:
                                      MainAxisAlignment.spaceAround,
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        await chatService
                                            .removeFriends(friendAppUser.uid);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontSize: UIConst.bodyLargeFontSize,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                            fontSize: UIConst.bodyLargeFontSize,
                                            color: UIConst.closeColor),
                                      ),
                                    )
                                  ],
                                  title: const Text('Warning!'),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: UIConst.bodyLargeFontSize,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Your chat with '),
                                        TextSpan(
                                            text: friendAppUser.displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                        const TextSpan(
                                            text:
                                                ' will be permanently deleted and cannot be restored')
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete),
                            color: UIConst.colorError,
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: Text(
              'Nobody here.... 🥹',
              style: TextStyle(
                fontSize: UIConst.displayLargeFontSize,
              ),
            ),
          );
        }
      },
    );
  }
}
