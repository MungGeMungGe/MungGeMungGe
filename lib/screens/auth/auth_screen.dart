import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:mung_ge_mung_ge/providers/auth_provider.dart';
import 'package:mung_ge_mung_ge/models/logInData.dart';

class AuthScreen extends StatefulWidget {

  //final signInModelProvider = ChangeNotifierProvider<LogInController>();

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  LoginRequestData _loginData = LoginRequestData();
  bool _obscureText = true;

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
                child: _getFormUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _getFormUI() {
    return new Column(
      children: <Widget>[
        Icon(
          Icons.cloud_circle_outlined,
          color: Colors.lightBlue,
          size: 150.0,
        ),
        new SizedBox(height: 50.0),
        new TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          //validator: FormValidator().validateEmail,
          onSaved: (String? value) {
            _loginData.email = value!;
          },
        ),
        new SizedBox(height: 20.0),
        new TextFormField(
            autofocus: false,
            obscureText: _obscureText,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  semanticLabel:
                  _obscureText ? 'show password' : 'hide password',
                ),
              ),
            ),
            //validator: FormValidator().validatePassword,
            onSaved: (String? value) {
              _loginData.password = value!;
            }),
        new SizedBox(height: 15.0),
        new Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            child: Text('Log In', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              //ElevatedButton.styleFrom 에는 backgroundColor 속성이 없음
              backgroundColor: Colors.lightBlue,
              shape: StadiumBorder(),
            ),
            onPressed: (){},
          ),
        ),
        new TextButton(
          onPressed: _sendToRegisterPage,
          child: Text('Not a member? Sign up now',
              style: TextStyle(color: Colors.black54)),
        ),
        new SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              child: Icon(Icons.ac_unit),
              onTap: (){},
            ),
            InkWell(
              child: Icon(Icons.ac_unit),
              onTap: (){},
            ),
            InkWell(
              child: Icon(Icons.ac_unit),
              onTap: (){},
            )
          ],
        )
      ],
    );
  }

  _sendToRegisterPage() {
    ///Go to register page
  }

  _sendToServer() {
    if (_key.currentState!.validate()) {
      /// No any error in validation
      _key.currentState!.save();
      print("Email ${_loginData.email}");
      print("Password ${_loginData.password}");
    } else {
      ///validation error
      setState(() {
        _validate = true;
      });
    }
  }
}


