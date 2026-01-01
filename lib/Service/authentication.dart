import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/Service/shared_pref.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BuildContext context;

  Authentication({required this.context});

  // Password encryption
  String encryptSHA256(String input) {
    var bytes = utf8.encode(input); // Convert string to bytes
    var digest = sha256.convert(bytes); // Apply SHA-256 hash
    return digest.toString(); // Convert hash to string
  }

  // Login and Signup both in one function
  Future<void> signInWithEmailPassword(
    BuildContext context,
    bool isLogin,
    String email,
    String password,
  ) async {
    try {
      if (isLogin) {
        // LOGIN
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: encryptSHA256(password),
        );
        CommonFunctions.logger.d("Login successful $email");
      } else {
        // SIGN-UP

        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: encryptSHA256(password),
        );
        CommonFunctions.logger.d("Signup successful $email");

        // Save user details to Firestore asynchronously
        DocumentReference docRef = await _firestore.collection("Users").add({
          "uid": "",
          "email": email,
          "login_method": "Email and password",
          // "password": encryptSHA256(password),
          "joined": DateFormat("dd MMM yyyy hh:mm a").format(DateTime.now()),
        });

        await docRef.update({"uid": docRef.id}).whenComplete(() {
          CommonFunctions.logger.d("User added successfully!");
        });
      }

      await SharedPrefService.saveLoginInfo(true, email);
      String status = isLogin ? "login" : "signup";
      // Navigate to HomeScreen screen after successful login/signup
      Navigator.pop(context, status);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered. Please log in.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'user-not-found') {
        errorMessage = "No account found for this email.";
      } else if (e.code == "invalid-credential") {
        errorMessage = "No such user";
      } else {
        errorMessage = e.code;
      }

      scaffoldMessenger(context, errorMessage);
    }
  }

  Future<void> logOutuser() async {
    await _auth.signOut();
    await SharedPrefService.saveLoginInfo(false, "");
  }
}
