import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInAuth {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static Future<User?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
    } catch (e, st) {
      print("Google Sign-In Error: $e\n$st");
    }
    return null;
  }

  static Future<void> signOutGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await auth.signOut();
    } catch (e) {
      //...
    }
  }

  static Future<void> createUser(
      {required String uid, required UserModel userModel}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      await db.collection('users').doc(uid).set(userModel.toJson());
    } catch (e) {
      print("GoogleSignInAuth createUser :: $e");
    }
  }

  static Future<void> userUpdate(
      {required String uid, required UserModel userModel}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      db.collection('users').doc(uid).update(userModel.toJson());
      AppPreference.setUser(userModel);
    } catch (e) {
      //...
    }
  }
}
