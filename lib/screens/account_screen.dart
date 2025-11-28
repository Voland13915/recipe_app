import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Name'),
            subtitle: const Text('Devina Hermawan'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: const Text('devina@example.com'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Password'),
            subtitle: const Text('Last updated 2 months ago'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }
}
