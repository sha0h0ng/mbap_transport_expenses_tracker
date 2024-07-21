import 'package:flutter/material.dart';

import 'package:transport_expenses_tracker/widgets/login_form.dart';
import 'package:transport_expenses_tracker/widgets/register_form.dart';
import 'package:transport_expenses_tracker/screens/reset_password_screen.dart';

class AuthScreen extends StatefulWidget {
  static String routeName = '/auth';
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool loginScreen = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Transport Expenses Tracker'),
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              loginScreen ? LoginForm() : RegisterForm(),
              const SizedBox(height: 5),
              loginScreen
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          loginScreen = false;
                        });
                      },
                      child: const Text('No account? Sign up here!'))
                  : TextButton(
                      onPressed: () {
                        setState(() {
                          loginScreen = true;
                        });
                      },
                      child: const Text('Existing user? Login in here!')),
              loginScreen
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(ResetPasswordScreen.routeName);
                      },
                      child: const Text('Forgotten Password'))
                  : const Center()
            ],
          )),
    );
  }
}
