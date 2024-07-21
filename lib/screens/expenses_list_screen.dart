import 'package:flutter/material.dart';
import 'package:transport_expenses_tracker/screens/add_expense_screen.dart';
import 'package:transport_expenses_tracker/widgets/app_drawer.dart';
import 'package:transport_expenses_tracker/widgets/my_expenses.dart';

class ExpensesListScreen extends StatelessWidget {
  static String routeName = '/expenses-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Expenses'),
      ),
      body: MyExpenses(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AddExpenseScreen.routeName);
          },
          child: const Icon(Icons.add)),
    );
  }
}
