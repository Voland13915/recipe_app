// profile_screen
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:nutrition_app/widgets/widgets.dart';  // Изменён путь
import 'package:provider/provider.dart';
import 'package:nutrition_app/provider/user_provider.dart';
import 'app_info_screen.dart';
import 'account_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 6.0.h,
              ),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(
                height: 4.0.h,
              ),
              const ProfileHeader(),
              const ProfileListView()
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileListView extends StatelessWidget {
  const ProfileListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          children: [
            ProfileListTile(
              text: 'Account',
              icon: UniconsLine.user_circle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AccountScreen(),
                  ),
                );
              },
            ),
            Divider(
              color: Colors.grey.shade400,
              indent: 10.0,
              endIndent: 10.0,
            ),
            ProfileListTile(
              text: 'Settings',
              icon: UniconsLine.setting,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            Divider(
              color: Colors.grey.shade400,
              indent: 10.0,
              endIndent: 10.0,
            ),
            ProfileListTile(
              text: 'App Info',
              icon: UniconsLine.info_circle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AppInfoScreen(),
                  ),
                );
              },
            ),
            Divider(
              color: Colors.grey.shade400,
              indent: 10.0,
              endIndent: 10.0,
            ),
            ProfileListTile(
              text: 'Logout',
              icon: UniconsLine.sign_out_alt,
              onTap: () => _showLogoutDialog(context),
            ),
          ]),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out? You can always sign back in later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if ((shouldLogout ?? false) && context.mounted) {
      context.read<UserProfile>().logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been logged out.'),
        ),
      );
    }
  }
}

class ProfileListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  const ProfileListTile({
    Key? key,
    required this.text,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.headlineMedium),
      horizontalTitleGap: 5.0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(icon, color: Theme.of(context).iconTheme.color),
      ),
      trailing: Icon(
        UniconsLine.angle_right,
        size: 24.0.sp,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProfile>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileImage(
            height: 20.0.h,
            image: user.profileImageUrl),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(user.email, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}