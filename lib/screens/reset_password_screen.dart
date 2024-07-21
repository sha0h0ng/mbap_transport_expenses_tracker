import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_expenses_tracker/services/firebase_service.dart';

class ResetPasswordScreen extends StatelessWidget {
  static String routeName = '/reset-password';
  String? email;
  var form = GlobalKey<FormState>();

  FirebaseService fbService = GetIt.instance<FirebaseService>();

  reset(context) {
    bool isValid = form.currentState!.validate();
    if (isValid) {
      form.currentState!.save();
      return fbService.forgetPassword(email).then((value) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please check your email for to reset your password!'),
          ),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        FocusScope.of(context).unfocus();
        String message = error.toString();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Transport Expenses Tracker'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text('Email')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null) {
                    return "Please provide an email address.";
                  } else if (!value.contains('@')) {
                    return "Please provide a valid email address.";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    reset(context);
                  },
                  child: const Text('Reset Password')),
            ],
          ),
        ),
      ),
    );
  }
}
