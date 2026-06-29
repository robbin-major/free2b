import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInAuth {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static const String _serverClientId =
      '1039187320593-3rmm8srkatnlh74v7j446lpa6gddrojq.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: _serverClientId,
  );

  static Future<User?> signInWithGoogle() async {
    try {
      debugPrint('GoogleSignInAuth: opening Google account picker');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('GoogleSignInAuth: signIn returned null or was cancelled');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        debugPrint(
          'GoogleSignInAuth: idToken is null. Check Firebase Google provider, '
          'web client id, google-services.json, and Play app signing SHA.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
    } on PlatformException catch (e, st) {
      debugPrint(
        'GoogleSignInAuth PlatformException: code=${e.code}, '
        'message=${e.message}, details=${e.details}\n$st',
      );
    } on FirebaseAuthException catch (e, st) {
      debugPrint(
        'GoogleSignInAuth FirebaseAuthException: code=${e.code}, '
        'message=${e.message}, email=${e.email}, credential=${e.credential}\n$st',
      );
    } catch (e, st) {
      debugPrint("Google Sign-In Error: $e\n$st");
    }
    return null;
  }

  static Future<void> signOutGoogle({required BuildContext context}) async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
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
