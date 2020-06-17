import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiggybackend/services/auth_service.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (input){
                  if(input.isEmpty){
                    return 'Email cannot be empty';
                  }
                  return null;
                },
                onSaved: (input){
                  _email = input;
                },
                decoration: inputDecoration('Email'),
              ),
              TextFormField(
                obscureText: true,
                validator: (input){
                  if(input.isEmpty){
                    return 'Password cannot be empty';
                  }
                  else if(input.length < 6){
                    return 'Password is too short';
                  }
                  return null;
                },
                onSaved: (input){
                  _password = input;
                },
                decoration: inputDecoration('Password'),
              ),
              RaisedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  signIn();
                },
                child: Text('Sign in'),
                color: Colors.blue,
              ),
              RaisedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  signUp();
                },
                child: Text('Register'),
                color: Colors.blue,
              )
            ],
          ),
        )
      ),
    );
  }

  InputDecoration inputDecoration(String hint){
    return InputDecoration(
      hintText: hint,
      contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    );
  }

  void signIn() async{
    final formState = _formKey.currentState;
    if(formState.validate()){
      formState.save();
      try{
        dynamic result = await _auth.signInWithEmailAndPassword(_email, _password);
        if(result != null){
          Fluttertoast.showToast(
              msg: result,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
      catch(e){
        print(e);
      }
    }
  }

  void signUp() async{
    final formState = _formKey.currentState;
    if(formState.validate()){
      formState.save();
      dynamic result = await _auth.signUpWithEmailAndPassword(_email, _password);
      if(result != null){
        Fluttertoast.showToast(
            msg: result,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

}
