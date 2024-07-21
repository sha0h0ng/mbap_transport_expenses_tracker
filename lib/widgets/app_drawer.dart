import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_expenses_tracker/services/theme_service.dart';
import 'package:transport_expenses_tracker/main.dart';
import 'package:transport_expenses_tracker/screens/expenses_list_screen.dart';
import 'package:transport_expenses_tracker/services/firebase_service.dart';

class AppDrawer extends StatelessWidget {
  FirebaseService fbService = GetIt.instance<FirebaseService>();
  ThemeService themeService = GetIt.instance<ThemeService>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: fbService.getCurrentUser() == null
              ? const Text("Hello Friend!")
              : FittedBox(
                  child: Text("Hello ${fbService.getCurrentUser()!.email!}!"),
                ),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(MainScreen.routeName),
        ),
        const Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: const Icon(Icons.monetization_on),
          title: const Text('My Expenses'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(ExpensesListScreen.routeName),
        ),
        const Divider(height: 3, color: Colors.blueGrey),
        ListTile(
          leading: const Icon(Icons.palette),
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Themes'),
            GestureDetector(
              child: CircleAvatar(
                  backgroundColor: Colors.deepPurple, maxRadius: 15),
              onTap: () {
                themeService.setTheme(Colors.deepPurple, 'deepPurple');
              },
            ),
            GestureDetector(
              child: CircleAvatar(backgroundColor: Colors.blue, maxRadius: 15),
              onTap: () {
                themeService.setTheme(Colors.blue, 'blue');
              },
            ),
            GestureDetector(
              child: CircleAvatar(backgroundColor: Colors.green, maxRadius: 15),
              onTap: () {
                themeService.setTheme(Colors.green, 'green');
              },
            ),
            GestureDetector(
              child: CircleAvatar(backgroundColor: Colors.red, maxRadius: 15),
              onTap: () {
                themeService.setTheme(Colors.red, 'red');
              },
            ),
          ]),
        ),
      ]),
    );
  }
}
