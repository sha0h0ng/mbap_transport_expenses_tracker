import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_expenses_tracker/firebase_options.dart';
import 'package:transport_expenses_tracker/models/expense.dart';
import 'package:transport_expenses_tracker/screens/add_expense_screen.dart';
import 'package:transport_expenses_tracker/screens/auth_screen.dart';
import 'package:transport_expenses_tracker/screens/edit_expense_screen.dart';
import 'package:transport_expenses_tracker/screens/expenses_list_screen.dart';
import 'package:transport_expenses_tracker/services/firebase_service.dart';
import 'package:transport_expenses_tracker/services/theme_service.dart';
import 'package:transport_expenses_tracker/widgets/app_drawer.dart';
import 'package:transport_expenses_tracker/screens/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GetIt.instance.registerLazySingleton(() => FirebaseService());
  GetIt.instance.registerLazySingleton(() => ThemeService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseService fbService = GetIt.instance<FirebaseService>();
  final ThemeService themeService = GetIt.instance<ThemeService>();

  @override
  Widget build(BuildContext context) {
    themeService.loadTheme();
    return StreamBuilder<User?>(
      stream: fbService.getAuthUser(),
      builder: (context, snapshot) {
        return StreamBuilder<Color>(
            stream: themeService.getThemeStream(),
            builder: (contextTheme, snapshotTheme) {
              return MaterialApp(
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: snapshotTheme.data ?? Colors.deepPurple),
                  useMaterial3: true,
                ),
                home: snapshot.connectionState != ConnectionState.waiting &&
                        snapshot.hasData
                    ? MainScreen()
                    : AuthScreen(),
                routes: {
                  AddExpenseScreen.routeName: (context) => AddExpenseScreen(),
                  ExpensesListScreen.routeName: (context) =>
                      ExpensesListScreen(),
                  EditExpenseScreen.routeName: (context) => EditExpenseScreen(),
                  ResetPasswordScreen.routeName: (context) =>
                      ResetPasswordScreen(),
                  AuthScreen.routeName: (context) => AuthScreen(),
                },
                debugShowCheckedModeBanner: false,
              );
            });
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  final FirebaseService fbService = GetIt.instance<FirebaseService>();
  static String routeName = '/';

  logOut(context) {
    return fbService.logOut().then((value) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Logout successfully!'),
      ));
    }).catchError((error) {
      FocusScope.of(context).unfocus();
      String message = error.toString();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
        stream: fbService.getExpense(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // For debugging purposes
          // if (snapshot.hasError) {
          //   debugPrint('Error: ${snapshot.error}');
          //   return const Center(child: Text('Error fetching data'));
          // }

          // For debugging purposes
          // if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //   debugPrint('No data available');
          //   return const Center(child: Text('No data available'));
          // }

          double sum = 0;
          snapshot.data!.forEach((doc) {
            sum += doc.cost;
          });

          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Transport Expenses Tracker'),
              actions: [
                IconButton(
                  onPressed: () => logOut(context),
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Center(
              child: Column(
                children: [
                  Image.asset('images/creditcard.png'),
                  Text('Total Spent: \$ ${sum.toStringAsFixed(2)}')
                ],
              ),
            ),
          );
        });
  }
}
