import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mung_ge_mung_ge/models/signUpData.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _key = new GlobalKey();
  final SignUpData _signUpData = SignUpData();
  final FirebaseAuth fAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(20.0),
            child: Center(
              child: new Form(
                key: _key,
                child: _signUpFormUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpFormUI() {
    return  Column(
      children: <Widget>[
        renderAuthField(),
        SizedBox(height: 15.0),
        renderSignUpButton(),
        SizedBox(height: 15.0),
      ],
    );
  }


  renderAuthField() {
    return Column(
      children: <Widget>[
        new TextFormField(
            autofocus: false,
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: '닉네임',
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onSaved: (String? value) {
              _signUpData.nickname(value!);
            }),
        new TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: (String? value) {
            if(value!.isNotEmpty && !EmailValidator.validate(value))
              return "이메일을 확인 후 다시 입력해 주세요.";
            return null;
          },
          onSaved: (String? value) {
            _signUpData.setEmail(value!);
          },
        ),
        new SizedBox(height: 20.0),
        new TextFormField(
            autofocus: false,
            obscureText: true,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onSaved: (String? value) {
              _signUpData.setPassword(value!);
            }),
      ],
    );
  }

  renderSignUpButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        child: Text('Log In', style: TextStyle(color: Colors.white)),
        style: TextButton.styleFrom(
          //ElevatedButton.styleFrom 에는 backgroundColor 속성이 없음
          backgroundColor: Colors.lightBlue,
          shape: StadiumBorder(),
        ),
        onPressed: renderSignUp(),
      ),
    );
  }


  renderSignUp() async {
    try {
      var result = await fAuth.createUserWithEmailAndPassword(
          email: _signUpData.email, password: _signUpData.password);
      if (result.user != null) {
        result.user!.sendEmailVerification();
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

}
