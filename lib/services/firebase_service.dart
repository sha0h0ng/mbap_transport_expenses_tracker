import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:transport_expenses_tracker/models/expense.dart';

class FirebaseService {
  Future<void> addExpense(String imageUrl, String purpose, String mode,
      double cost, DateTime travelDate) {
    return FirebaseFirestore.instance.collection('expenses').add({
      'imageUrl': imageUrl,
      'email': getCurrentUser()!.email,
      'purpose': purpose,
      'mode': mode,
      'cost': cost,
      'travelDate': travelDate
    });
  }

  Stream<List<Expense>> getExpense() {
    return FirebaseFirestore.instance
        .collection('expenses')
        .where('email', isEqualTo: getCurrentUser()!.email)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense(
                id: doc.id,
                imageUrl: doc.data()['imageUrl'] ?? '',
                purpose: doc.data()['purpose'] ?? '',
                mode: doc.data()['mode'] ?? '',
                // cost: doc.data()['cost'] ?? 0, -> Causing error because it is reading as int and not double
                // Convert cost to double
                cost: doc['cost'] is int
                    ? (doc['cost'] as int).toDouble()
                    : doc['cost'],
                travelDate:
                    (doc.data()['travelDate'] ?? DateTime.now() as Timestamp)
                        .toDate()))
            .toList());
  }

  // Depends on your code, it might be updateExpense or editExpense
  Future<void> editExpense(String imageUrl, String id, String purpose,
      String mode, double cost, DateTime travelDate) {
    return FirebaseFirestore.instance.collection('expenses').doc(id).update({
      'imageUrl': imageUrl,
      'purpose': purpose,
      'mode': mode,
      'cost': cost,
      'travelDate': travelDate
    });
  }

  // Upload file into Firebase Storage
  Future<String?> addReceiptPhotoFromFile(File receiptPhoto) {
    return FirebaseStorage.instance
        .ref()
        .child(DateTime.now().toString() + '_' + basename(receiptPhoto.path))
        .putFile(receiptPhoto)
        .then((task) {
      return task.ref.getDownloadURL().then((imageUrl) {
        return imageUrl;
      });
    });
  }

  // Upload base64 image into Firebase Storage
  Future<String?> addReceiptPhotoFromBase64(String base64Image) {
    Uint8List bytes = base64Decode(base64Image);
    String fileName = DateTime.now().toString() + '_image.png';
    Reference ref = FirebaseStorage.instance.ref().child(fileName);

    return ref.putData(bytes).then((task) {
      return task.ref.getDownloadURL().then((imageUrl) {
        return imageUrl;
      });
    });
  }

  Future<void> deleteExpense(String id) {
    return FirebaseFirestore.instance.collection('expenses').doc(id).delete();
  }

  Future<UserCredential> register(email, password) {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> login(email, password) {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> forgetPassword(email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Stream<User?> getAuthUser() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<void> logOut() {
    return FirebaseAuth.instance.signOut();
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
