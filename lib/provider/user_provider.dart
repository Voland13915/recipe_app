import 'package:flutter/material.dart';

class UserProfile extends ChangeNotifier {
  UserProfile({
    String? name,
    String? email,
    String? password,
    String? profileImageUrl,
  })  : _name = name ?? '',
        _email = email ?? '',
        _password = password ?? '',
        _profileImageUrl = profileImageUrl ?? _defaultImageUrl;

  static const String _defaultImageUrl =
      'https://avatars.mds.yandex.net/i?id=90e4d998805789a1184caa7e660bc922_l-5869421-images-thumbs&n=13';

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
  void logout() {
    _name = '';
    _email = '';
    _password = '';
    _profileImageUrl = _defaultImageUrl;
    notifyListeners();
  }
}