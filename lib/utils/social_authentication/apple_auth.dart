import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInAuth {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String? lastErrorMessage;

  static Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<User?> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      lastErrorMessage = null;
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final String? identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        lastErrorMessage =
            'Apple sign-in did not return an identity token. Please try again.';
        return null;
      }

      final fullName = AppleFullPersonName(
        givenName: appleCredential.givenName,
        familyName: appleCredential.familyName,
      );

      final oauthCredential = AppleAuthProvider.credentialWithIDToken(
        identityToken,
        rawNonce,
        fullName,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      final firebaseUser = authResult.user;
      final displayName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join(' ');

      if (firebaseUser != null && displayName.isNotEmpty) {
        await firebaseUser.updateDisplayName(displayName);
        await firebaseUser.reload();
      }

      return _firebaseAuth.currentUser ?? firebaseUser;
    } on SignInWithAppleAuthorizationException catch (exception) {
      lastErrorMessage = exception.code == AuthorizationErrorCode.canceled
          ? 'Apple sign-in was cancelled.'
          : 'Apple sign-in could not complete. Please try again.';
      print("Apple sign-in authorization exception $exception");
    } on FirebaseAuthException catch (exception) {
      lastErrorMessage =
          exception.message ?? 'Firebase could not complete Apple sign-in.';
      print(
        "Apple sign-in FirebaseAuthException "
        "code=${exception.code}, message=${exception.message}",
      );
    } catch (exception) {
      lastErrorMessage = 'Apple sign-in failed. Please try again.';
      print("Apple sign-in exception $exception");
    }
    return null;
  }
}
