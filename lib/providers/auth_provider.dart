import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LogInController with ChangeNotifier {
  LogInController({required this.auth});

  FirebaseAuth auth;
  dynamic error;

  Future<void> _logIn(String method, dynamic token) async{
    try{
      notifyListeners();
      switch (method) {
       // case "self" :
        case "google":
          auth.signInWithCredential(token);
          break;
        case "apple":
          auth.signInWithCredential(token);
          break;
      }
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;
        if (googleAuth.accessToken != null && googleAuth.idToken != null) {
          _logIn(
              "google",
              GoogleAuthProvider.credential(
                  idToken: googleAuth.idToken,
                  accessToken: googleAuth.accessToken));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email]);
      final tokenCredential = OAuthProvider('apple.com').credential(
          accessToken: appleCredential.authorizationCode,
          idToken: appleCredential.identityToken);
      _logIn("apple", tokenCredential);
    } catch (e) {
      print(e);
    }
  }


}