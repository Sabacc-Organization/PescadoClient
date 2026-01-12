import 'dart:convert';
import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/main.dart';
import 'package:PescadoClient/network/connection.dart';
import 'package:PescadoClient/screens/page_template.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);
    return PageTemplateW(
      child: Center(
        child: SimpleCardW(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              SimpleTextFieldW(hint: "username", controller: _usernameController,),
              SimpleTextFieldW(hint: "password", controller: _passwordController, obscureText: true,),
              SimpleTextFieldW(hint: "confirm password", controller: _passwordConfirmController, obscureText: true,),
              if (_errorMessage != null) SelectableText(
                _errorMessage?? "",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SimpleTextButtonW(
                onClick: () {
                  SabaccConnectionManager.register(
                    context,
                    username: _usernameController.text,
                    password: _passwordController.text,
                    confirmPassword: _passwordConfirmController.text,
                    callback: (res) {
                      print(res.body);
                      if (200 <= res.statusCode && res.statusCode < 300) {
                        appwideData.logIn(_usernameController.text, _passwordController.text);
                        context.go("/");
                      } else {
                        var message = (json.decode(res.body) as Map<String, dynamic>)["message"];
                        setState(() {
                          _errorMessage = message?? "There was an error. Please try again.";
                        });
                      }
                    }
                  );
                },
                text: "Register"
              )
            ],
          ),
        ),
      )
    );
  }
}