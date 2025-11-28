import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle:
                const Text('Receive push notifications about new recipes'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              settings.toggleNotifications(value);
              _showFeedbackMessage(
                context,
                value
                    ? 'Notifications enabled'
                    : 'Notifications disabled',
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme across the app'),
            value: settings.isDarkMode,
            onChanged: settings.toggleDarkMode,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: Text(_languageLabel(settings.locale.languageCode)),
            onTap: () => _showLanguageSheet(context, settings),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_clock_outlined),
            title: const Text('Privacy'),
            subtitle: const Text('Manage data and permissions'),
            onTap: () => _showPrivacySheet(context, settings),
          ),
        ],
      ),
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguageSheet(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: settings.locale,
                onChanged: (value) {
                  if (value != null) {
                    settings.setLocale(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<Locale>(
                title: const Text('Русский'),
                value: const Locale('ru'),
                groupValue: settings.locale,
                onChanged: (value) {
                  if (value != null) {
                    settings.setLocale(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacySheet(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Privacy Preferences',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Personalized recommendations'),
                  subtitle: const Text(
                    'Allow us to tailor recipe suggestions based on your activity.',
                  ),
                  value: settings.personalizedAds,
                  onChanged: settings.togglePersonalizedAds,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Share anonymous analytics'),
                  subtitle: const Text(
                    'Help us improve the app by sharing anonymized usage data.',
                  ),
                  value: settings.dataSharingEnabled,
                  onChanged: settings.toggleDataSharing,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
