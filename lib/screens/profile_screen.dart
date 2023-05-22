import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whisper/const/ui_const.dart';
import 'package:whisper/models/app_user.dart';
import 'package:whisper/services/app_user_services.dart';
import 'package:whisper/services/image_picker_services.dart';
import 'package:whisper/services/storage_service.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String newPassword = '';
  bool isGoogleSignIn = false;

  @override
  Widget build(BuildContext context) {
    Future<AppUser> futureUser =
        AppUserService().getUserByUid(AuthService().currentUser!.uid);
    return FutureBuilder<AppUser>(
      future: futureUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        isGoogleSignIn =
            AuthService().currentUser!.providerData.first.providerId ==
                'google.com';
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(user!.avatarUrl),
                ),
                Text(
                  user.displayName!,
                  style: TextStyle(
                    fontSize: UIConst.bodyLargeFontSize,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      20,
                    ),
                  ),
                  onPressed: () async {
                    var img = await ImagePickerService()
                        .pickImage(ImageSource.gallery);

                    await StorageService().saveAvatar(img!);
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.upload_sharp,
                    size: UIConst.displayLargeFontSize,
                  ),
                  label: const Text('Change avatar'),
                ),
                if (!isGoogleSignIn)
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          20,
                        ),
                      ),
                      onPressed: () {
                        showBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 250,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      label: Text('New password'),
                                      hintText: 'Type your new password',
                                    ),
                                    onChanged: (value) {
                                      newPassword = value;
                                    },
                                  ),
                                ),
                              ),
                              if (AuthService()
                                      .currentUser!
                                      .providerData
                                      .first
                                      .providerId ==
                                  'google.com')
                                OutlinedButton(
                                  onPressed: () async {
                                    if (newPassword.isEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'New password must not empty!',
                                              style: TextStyle(
                                                color: UIConst.colorError,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    if (newPassword.length < 6) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'New password must longer than 6 character!',
                                            style: TextStyle(
                                              color: UIConst.colorError,
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    await AuthService()
                                        .updatePassword(newPassword);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Change password successfully!',
                                            style: TextStyle(
                                              color: UIConst.colorSchemeSeed,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    await AuthService().signOut();
                                  },
                                  child: const Icon(
                                    Icons.check,
                                  ),
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.lock_reset,
                        size: UIConst.displayLargeFontSize,
                      ),
                      label: const Text('Change password')),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().signOut();
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: UIConst.closeColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
