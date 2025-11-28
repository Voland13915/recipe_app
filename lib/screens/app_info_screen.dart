import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Info'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Nutrition App'),
            subtitle: Text('Version 1.0.0'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.article_outlined),
            title: Text('Terms of Service'),
            subtitle: Text('Read how we handle your data and content'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Privacy Policy'),
            subtitle: Text('Understand the information we collect and how we use it'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.support_agent_outlined),
            title: Text('Support'),
            subtitle: Text('Contact support@nutrition.app for help'),
          ),
        ],
      ),
    );
  }
}
