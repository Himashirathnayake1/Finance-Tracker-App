import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Provider that manages Firebase Authentication logic.
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get currentUser => _user;

  AuthProvider() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((event) {
      _user = event;
      notifyListeners();
    });
  }
  //register user with email & password
Future<String?> register(String email, String password) async {
  try {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return null; // Success
  } on FirebaseAuthException catch (e) {
    return _getErrorMessage(e);
  } catch (e) {
    return "Something went wrong. Please try again.";
  }
}
//login
Future<String?> login(String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return null;
  } on FirebaseAuthException catch (e) {
    return _getErrorMessage(e);
  } catch (e) {
    return "Something went wrong. Please try again.";
  }
}


  /// Logout user
  Future<void> logout() async => await _auth.signOut();

  /// Friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Please enter a valid email address.";
      case 'weak-password':
        return "Your password is too weak. It should be at least 6 characters.";
      case 'email-already-in-use':
        return "This email is already registered. Try logging in.";
      case 'user-not-found':
        return "No account found with this email. Please register first.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'network-request-failed':
        return "No internet connection. Please check your network.";
      default:
        return "An unexpected error occurred. Please try again.";
    }
  }
}
