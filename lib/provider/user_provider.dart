import 'package:flutter/material.dart';

class UserProfile extends ChangeNotifier {
  UserProfile({
    String? name,
    String? email,
    String? password,
    String? profileImageUrl,
  })  : _name = name ?? 'Devina Hermawan',
        _email = email ?? 'devina@example.com',
        _password = password ?? 'password123',
        _profileImageUrl = profileImageUrl ??
            'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1740&q=80';

  String _name;
  String _email;
  String _password;
  String _profileImageUrl;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get profileImageUrl => _profileImageUrl;

  void updateProfile({
    String? name,
    String? email,
    String? password,
    String? profileImageUrl,
  }) {
    if (name != null && name.trim().isNotEmpty) {
      _name = name.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      _email = email.trim();
    }
    if (password != null && password.trim().isNotEmpty) {
      _password = password.trim();
    }
    if (profileImageUrl != null && profileImageUrl.trim().isNotEmpty) {
      _profileImageUrl = profileImageUrl.trim();
    }
    notifyListeners();
  }
}