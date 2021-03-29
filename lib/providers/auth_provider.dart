import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mung_ge_mung_ge/models/logInData.dart';


class LogInController with ChangeNotifier {
  LogInController({required this.auth});

  final FirebaseAuth auth;
  dynamic error;

  Future<void> _logIn(String method, dynamic token) async{
    try{
      notifyListeners();
      switch (method) {
       // case "self" :
        case "google":
          auth.signInWithCredential(token);
      }
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signInWithSelf(LoginRequestData logInData) async{
    try {
      var result = await auth.signInWithEmailAndPassword(
          email: logInData.email, password: logInData.password);
      if(result != null) {
        
      }
    } catch(e) {

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
    } finally {
    }
  }



}