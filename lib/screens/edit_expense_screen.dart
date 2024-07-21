import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:transport_expenses_tracker/models/expense.dart';
import 'package:transport_expenses_tracker/services/firebase_service.dart';

class EditExpenseScreen extends StatefulWidget {
  static String routeName = '/edit-expense';

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final FirebaseService fbService = GetIt.instance<FirebaseService>();
  var form = GlobalKey<FormState>();

  String? purpose;
  String? mode;
  double? cost;
  DateTime? travelDate;
  String? imageUrl;
  File? receiptPhoto; // For mobile
  String? base64Image; // For web

  Future<void> pickImage(int mode) async {
    // Using kIsWeb to check if the platform is Web
    if (kIsWeb) {
      // For Web
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // Check if the user has selected a file
      // If the user has selected a file, convert the file to base64
      if (result != null) {
        Uint8List fileBytes = result.files.first.bytes!;
        String base64String = base64Encode(fileBytes);
        setState(() {
          base64Image = base64String;
          receiptPhoto = null; // Clear receiptPhoto for web
        });
      }
    } else {
      // For Mobile
      ImageSource chosenSource =
          mode == 0 ? ImageSource.camera : ImageSource.gallery;
      final pickedFile = await ImagePicker().pickImage(
        source: chosenSource,
        maxWidth: 600,
        imageQuality: 50,
        maxHeight: 150,
      );

      // Check if the user has selected a file
      // If the user has selected a file, set the receiptPhoto
      if (pickedFile != null) {
        setState(() {
          receiptPhoto = File(pickedFile.path);
          base64Image = null; // Clear base64Image for mobile
        });
      }
    }
  }

  void saveForm(String id) {
    travelDate ??= DateTime.now();

    if (form.currentState!.validate()) {
      form.currentState!.save();
      debugPrint('Purpose: $purpose');
      debugPrint('Mode: $mode');
      debugPrint('Cost: ${cost!.toStringAsFixed(2)}');
      debugPrint(
          'Travel Date: ${DateFormat('dd/MM/yyyy').format(travelDate!)}');
      debugPrint('Receipt Photo: $imageUrl');

      // Using kIsWeb to check if the platform is Web
      if (kIsWeb) {
        // For Web
        if (base64Image != null) {
          // If the user has selected a file, upload the file to Firebase Storage
          fbService.addReceiptPhotoFromBase64(base64Image!).then((imageUrl) {
            _updateExpense(id, imageUrl!, purpose!, mode!, cost!, travelDate!);
          }).catchError((error, stackTrace) => _handleError(error));
        } else {
          // If the user has not selected a file, update the expense without changing the image
          // imageUrl is null when the user has not selected a file
          _updateExpense(
              id, imageUrl ?? '', purpose!, mode!, cost!, travelDate!);
        }
      } else {
        // For Mobile
        if (receiptPhoto != null) {
          // If the user has selected a file, upload the file to Firebase Storage
          fbService.addReceiptPhotoFromFile(receiptPhoto!).then((imageUrl) {
            _updateExpense(id, imageUrl!, purpose!, mode!, cost!, travelDate!);
          }).catchError((error, stackTrace) => _handleError(error));
        } else {
          // If the user has not selected a file, update the expense without changing the image
          // imageUrl is null when the user has not selected a file
          _updateExpense(
              id, imageUrl ?? '', purpose!, mode!, cost!, travelDate!);
        }
      }
    }
  }

  // Update the expense in Firestore
  void _updateExpense(String id, String imageUrl, String purpose, String mode,
      double cost, DateTime travelDate) {
    fbService
        .editExpense(imageUrl, id, purpose, mode, cost, travelDate)
        .then((value) => _handleSuccess())
        .catchError((error, stackTrace) => _handleError(error));
  }

  // Handle a successful update
  void _handleSuccess() {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    // Reset the form
    form.currentState!.reset();
    travelDate = null;
    receiptPhoto = null;
    base64Image = null;

    // Show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Travel expense updated successfully!'),
    ));
    Navigator.of(context).pop();
  }

  // Handle an error
  void _handleError(Object error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $error')));
  }

  @override
  Widget build(BuildContext context) {
    Expense selectedExpense =
        ModalRoute.of(context)!.settings.arguments as Expense;

    travelDate ??= selectedExpense.travelDate;
    imageUrl ??= selectedExpense.imageUrl;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              saveForm(selectedExpense.id);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: form,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: selectedExpense.mode,
                decoration: const InputDecoration(
                  label: Text('Mode of Transport'),
                ),
                items: const [
                  DropdownMenuItem(value: 'bus', child: Text('Bus')),
                  DropdownMenuItem(value: 'grab', child: Text('Grab')),
                  DropdownMenuItem(value: 'mrt', child: Text('MRT')),
                  DropdownMenuItem(value: 'taxi', child: Text('Taxi')),
                ],
                onChanged: (value) {
                  mode = value as String?;
                },
                onSaved: (value) {
                  mode = value as String?;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a mode of transport';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                initialValue: selectedExpense.cost.toString(),
                decoration: const InputDecoration(label: Text('Cost')),
                onSaved: (value) {
                  cost = double.parse(value!);
                },
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a cost';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null; // no error
                },
              ),
              TextFormField(
                initialValue: selectedExpense.purpose,
                decoration: const InputDecoration(label: Text('Purpose')),
                onSaved: (value) {
                  purpose = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a purpose.';
                  } else if (value.length < 5) {
                    return 'Please enter a description that is at least 5 characters.';
                  } else {
                    return null;
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(() {
                    if (travelDate == null) {
                      return 'No date chosen';
                    } else {
                      return 'Date: ${DateFormat('dd/MM/yyyy').format(travelDate!)}';
                    }
                  }()),
                  TextButton(
                      child: const Text('Choose Date',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 14)),
                          lastDate: DateTime.now(),
                        ).then((value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            travelDate = value;
                          });
                        });
                      })
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 100,
                    decoration: const BoxDecoration(color: Colors.grey),
                    child: receiptPhoto != null
                        ? FittedBox(
                            fit: BoxFit.fill,
                            child: Image.file(receiptPhoto!),
                          )
                        : (kIsWeb && base64Image != null)
                            ? FittedBox(
                                fit: BoxFit.fill,
                                child: Image.memory(
                                  base64Decode(base64Image!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : imageUrl != ''
                                ? FittedBox(
                                    fit: BoxFit.fill,
                                    child: Image.network(
                                      imageUrl!,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        // Print the error to the debug console
                                        debugPrint(
                                            'Error loading image: $error');
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.error,
                                                  color: Colors.red),
                                              const SizedBox(height: 8),
                                              const Text(
                                                  'Failed to load image'),
                                              const SizedBox(height: 8),
                                              Text(error
                                                  .toString()), // Print error message to UI
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const Center(
                                    child: Text('No image selected'),
                                  ),
                  ),
                  Column(
                    children: [
                      TextButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => pickImage(0),
                          label: const Text('Take Photo')),
                      TextButton.icon(
                          icon: const Icon(Icons.image),
                          onPressed: () => pickImage(1),
                          label: const Text('Add Image')),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
