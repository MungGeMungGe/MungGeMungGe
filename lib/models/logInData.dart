import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginRequestData {
  late String _email;
  var _password;

  setEmail(String email){
    _email = email;
  }

  setPassword(String pw){
    var bytes = utf8.encode(pw);
    _password = sha256.convert(bytes);
  }

  get email => _email;
  get password => _password.toString();

}