import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:whisper/services/chat_services.dart';
import 'chat_list_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';
import '../const/ui_const.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    ChatListScreen(),
    FriendsScreen(),
    ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper'),
        centerTitle: true,
        backgroundColor: UIConst.colorSchemeSeed,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Chat',
            icon: Icon(
              Icons.chat,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Friends',
            icon: Icon(
              Icons.people,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(
              Icons.person,
            ),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          await showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                height: 200,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(UIConst.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email!';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Please input a valid email!';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _email = newValue!;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: UIConst.bodyLargeFontSize,
                                color: UIConst.closeColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                String message =
                                    await ChatService().createNewChat(_email);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Notification'),
                                      content: Text(
                                        message,
                                        style: TextStyle(
                                            fontSize:
                                                UIConst.bodyLargeFontSize),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Close',
                                            style: TextStyle(
                                                color: UIConst.closeColor,
                                                fontSize:
                                                    UIConst.bodyLargeFontSize),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'New Chat',
                              style: TextStyle(
                                  fontSize: UIConst.bodyLargeFontSize),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add_comment,
        ),
      ),
    );
  }
}
