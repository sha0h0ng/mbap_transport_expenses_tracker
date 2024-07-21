import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_expenses_tracker/models/expense.dart';
import 'package:transport_expenses_tracker/screens/edit_expense_screen.dart';
import 'package:transport_expenses_tracker/services/firebase_service.dart';

class MyExpenses extends StatefulWidget {
  @override
  State<MyExpenses> createState() => _MyExpensesState();
}

class _MyExpensesState extends State<MyExpenses> {
  final FirebaseService fbService = GetIt.instance<FirebaseService>();

  void deleteExpense(String id) {
    showDialog<Null>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Are you sure you want to delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    fbService.deleteExpense(id).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Travel expense deleted successfully!'),
                      ));
                    }).onError((error, stackTrace) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error: $error'),
                      ));
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
            ],
          );
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
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Image.asset('images/empty.png'),
                  const Text(
                      'No expenses found. Add some expenses to see them here.'),
                ],
              ),
            );
          }
          return ListView.separated(
              itemBuilder: (ctx, i) {
                return ListTile(
                    leading: CircleAvatar(
                      child: Text(snapshot.data![i].mode),
                    ),
                    title: Text(snapshot.data![i].purpose),
                    subtitle: Text(
                        'Cost: ${snapshot.data![i].cost.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.pushNamed(context, EditExpenseScreen.routeName,
                          arguments: snapshot.data![i]);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteExpense(snapshot.data![i].id);
                      },
                    ));
              },
              separatorBuilder: (ctx, i) {
                return const Divider(
                  height: 3,
                  color: Colors.blueGrey,
                );
              },
              itemCount: snapshot.data!.length);
        });
  }
}
