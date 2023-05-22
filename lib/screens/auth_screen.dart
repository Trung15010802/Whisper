import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../const/ui_const.dart';

import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegister = false;
  String _label = 'Login';

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _formPassResetKey = GlobalKey<FormState>();
  String _userName = '';
  String _email = '';
  String _password = '';

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_isRegister) {
      await AuthService().createUserWithEmailAndPassword(context,
          email: _email, password: _password, username: _userName);
    } else {
      await AuthService().signInWithEmailAndPassword(context,
          email: _email, password: _password);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: InteractiveViewer(
                      maxScale: 5,
                      child: Image.asset(
                        'assets/logo/cover.png',
                      ),
                    ),
                  ),
                  Flexible(
                    flex: _isRegister ? 6 : 3,
                    fit: FlexFit.tight,
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              AutoSizeText(
                                _label,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (_isRegister)
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    label: const Text('Username'),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          UIConst.borderRadius),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    if (value.length > 30) {
                                      return 'Username too long!';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _userName = newValue!.trim();
                                  },
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  label: const Text('Email'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        UIConst.borderRadius),
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
                                  _email = newValue!.trim();
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        UIConst.borderRadius),
                                  ),
                                  label: const Text('Password'),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password!';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must have atleast 6 character!';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _password = value;
                                },
                                onSaved: (newValue) {
                                  _password = newValue!.trim();
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (_isRegister)
                                TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          UIConst.borderRadius),
                                    ),
                                    label: const Text('Re-enter password'),
                                  ),
                                  validator: (value) {
                                    if (value != _password) {
                                      return "Password doesn't match";
                                    }
                                    return null;
                                  },
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  submit();
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    _label,
                                    style: TextStyle(
                                      fontSize: UIConst.bodyLargeFontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              if (!_isRegister) ...[
                                const SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    AuthService().googleSignIn(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image(
                                        image: const AssetImage(
                                            'assets/logo/google.png'),
                                        width: UIConst.iconSize,
                                      ),
                                      Text(
                                        'Login with google account',
                                        style: TextStyle(
                                          fontSize: UIConst.bodyLargeFontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          height: 200,
                                          child: Form(
                                            key: _formPassResetKey,
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  decoration: InputDecoration(
                                                    label: const Text('Email'),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(UIConst
                                                              .borderRadius),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter your email!';
                                                    }
                                                    if (!EmailValidator
                                                        .validate(value)) {
                                                      return 'Please input a valid email!';
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (newValue) {
                                                    _email = newValue!;
                                                  },
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          fontSize: UIConst
                                                              .bodyLargeFontSize,
                                                          color: UIConst
                                                              .closeColor,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        if (_formPassResetKey
                                                            .currentState!
                                                            .validate()) {
                                                          _formPassResetKey
                                                              .currentState!
                                                              .save();
                                                          try {
                                                            await AuthService()
                                                                .passwordReset(
                                                                    _email);

                                                            if (context
                                                                .mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      '✅ Sent confirmation link. Please check your email!'),
                                                                ),
                                                              );
                                                            }
                                                          } on FirebaseAuthException catch (e) {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      AlertDialog(
                                                                title: const Text(
                                                                    'Notification!'),
                                                                content: Text(
                                                                  e.message
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: UIConst
                                                                        .colorError,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      'Close',
                                                                      style: TextStyle(
                                                                          color: UIConst
                                                                              .closeColor,
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
                                                        'Send verification',
                                                        style: TextStyle(
                                                            fontSize: UIConst
                                                                .bodyLargeFontSize),
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
                                  child: Text(
                                    'Forgot password ?',
                                    style: TextStyle(
                                      fontSize: UIConst.bodyLargeFontSize,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Or',
                                style: TextStyle(
                                    fontSize: UIConst.bodyLargeFontSize),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(
                                    () {
                                      _isRegister = !_isRegister;
                                      _isRegister
                                          ? _label = 'Register'
                                          : _label = 'Login';
                                    },
                                  );
                                },
                                child: Text(
                                  _isRegister
                                      ? 'Already have acount ?'
                                      : 'Create a new account',
                                  style: TextStyle(
                                      fontSize: UIConst.bodyLargeFontSize),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
