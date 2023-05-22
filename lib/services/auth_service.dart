import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../const/ui_const.dart';
import '../models/app_user.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String? _errorMessage;
  get errorMessage => _errorMessage;
  final _userRepository = UserRepository();

  Future<void> signInWithEmailAndPassword(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Succesfully!'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      showSnackbarError(context, e.message.toString());
    }
  }

  Future<void> createUserWithEmailAndPassword(
    context, {
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      AppUser appUser = AppUser(
        uid: currentUser!.uid,
        displayName: username,
        email: currentUser!.email,
      );

      _userRepository.addNewUser(appUser);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register Succesfully!'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      showSnackbarError(
        context,
        e.message.toString(),
      );
    }
  }

  Future<void> googleSignIn(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(authCredential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        AppUser appUser = AppUser(
          uid: currentUser!.uid,
          displayName: googleUser.displayName,
          email: currentUser!.email,
        );
        _userRepository.addNewUser(appUser);
      }
    } on FirebaseAuthException catch (e) {
      showSnackbarError(
        context,
        e.message.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  void showSnackbarError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error,
          style: TextStyle(color: UIConst.colorError),
        ),
      ),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await currentUser!.updatePassword(newPassword);
  }

  Future<void> passwordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
