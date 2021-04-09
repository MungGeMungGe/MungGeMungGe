import 'package:crypto/crypto.dart';
import 'dart:convert';

class SignUpData {
  late String _nickname;
  late String _email;
  var _password;

  setNickname(String nickname){
    _nickname = nickname;
  }


  setEmail(String email){
    _email = email;
  }

  setPassword(String pw){
    var bytes = utf8.encode(pw);
    _password = sha256.convert(bytes);
  }

  get nickname => _nickname;
  get email => _email;
  get password => _password.toString();

}