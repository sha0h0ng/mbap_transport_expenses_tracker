import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_expenses_tracker/services/firebase_service.dart';

class LoginForm extends StatelessWidget {
  String? email;
  String? password;
  var form = GlobalKey<FormState>();

  FirebaseService fbService = GetIt.instance<FirebaseService>();

  login(context) {
    bool isValid = form.currentState!.validate();
    if (isValid) {
      form.currentState!.save();
      fbService.login(email, password).then((value) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Login successfully!'),
        ));
      }).catchError((error) {
        FocusScope.of(context).unfocus();
        String message = error.toString();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(label: Text('Email')),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null)
                return "Please provide an email address.";
              else if (!value.contains('@'))
                return "Please provide a valid email address.";
              else
                return null;
            },
            onSaved: (value) {
              email = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(label: Text('Password')),
            obscureText: true,
            validator: (value) {
              if (value == null)
                return 'Please provide a password.';
              else if (value.length < 6)
                return 'Password must be at least 6 characters.';
              else
                return null;
            },
            onSaved: (value) {
              password = value;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                login(context);
              },
              child: const Text('Login')),
        ],
      ),
    );
  }
}
