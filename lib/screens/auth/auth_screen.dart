import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mung_ge_mung_ge/providers/auth_provider.dart';
import 'package:mung_ge_mung_ge/models/logInData.dart';
import 'package:email_validator/email_validator.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => LogInController(auth: FirebaseAuth.instance),
      child: AuthScreenContent(),
    );
  }
}

class AuthScreenContent extends StatefulWidget {

  @override
  _AuthScreenContentState createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends State<AuthScreenContent> {
  final GlobalKey<FormState> _key = new GlobalKey();
  final LoginRequestData _loginData = LoginRequestData();
  final FirebaseAuth fAuth = FirebaseAuth.instance; //프로바이더로 생성

  @override
  Widget build(BuildContext context) {
    LogInController _logInModel = Provider.of<LogInController>(context);

    return new Scaffold(
      body: new Center(
        child: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(20.0),
            child: Center(
              child: new Form(
                key: _key,
                child: _getFormUI(_logInModel),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _getFormUI(LogInController _logInModel) {
    return  Column(
      children: <Widget>[
        renderLogo(),
        SizedBox(height: 50.0),
        renderAuthField(),
        SizedBox(height: 15.0),
        renderLogInButton(),
        renderRegisterButton(),
        SizedBox(height: 15.0),
        renderSocialLogIn(_logInModel),
      ],
    );
  }

  renderLogo() {
    return Icon(
      Icons.cloud_circle_outlined,
      color: Colors.lightBlue,
      size: 150.0,
    );
  }

  renderAuthField() {
    return Column(
      children: <Widget>[
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
            _loginData.setEmail(value!);
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
              _loginData.setPassword(value!);
            }),
      ],
    );
  }

  renderLogInButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        child: Text('Log In', style: TextStyle(color: Colors.white)),
        style: TextButton.styleFrom(
          //ElevatedButton.styleFrom 에는 backgroundColor 속성이 없음
          backgroundColor: Colors.lightBlue,
          shape: StadiumBorder(),
        ),
        onPressed: _sendToServer,
      ),
    );
  }

  renderRegisterButton() {
    return TextButton(
      onPressed: _sendToRegisterPage,
      child: Text('Not a member? Sign up now',
          style: TextStyle(color: Colors.black54)),
    );
  }

  renderSocialLogIn(LogInController _logInModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          child: Image.asset("assets/auth/google.png"),
          onTap: () async{
            await _logInModel.signInWithGoogle();
          },
        ),
        InkWell(
          child: Image.asset("assets/auth/apple.png"),
          onTap: () async{
            await _logInModel.signInWithApple();
          },
        ),
        InkWell(
          child: Icon(Icons.ac_unit),
          onTap: (){},
        )
      ],
    );
  }

  _sendToRegisterPage() {
    ///Go to register page
  }

  _sendToServer() async{
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      try {
        await fAuth.signInWithEmailAndPassword(
            email: _loginData.email, password: _loginData.password);
      } on Exception catch (e) {
        print(e);
      }
    }
  }
}

