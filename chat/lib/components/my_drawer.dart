import 'package:chat/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('lib/images/wolf.png', height: 200, width: 200),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Profile'),
                    leading: const Icon(Icons.person),
                    onTap: () => Navigator.pushNamed(context, '/profilePage'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25,),
                  child: ListTile(
                    title: const Text('Chat'),
                    leading: const Icon(Icons.chat),
                    onTap: () => Navigator.pushNamed(context, '/homePage'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Social'),
                    leading: const Icon(Icons.group),
                    onTap: () => Navigator.pushNamed(context, '/socialPage'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Settings'),
                    leading: const Icon(Icons.settings),
                    onTap: () => Navigator.pushNamed(context, '/settingsPage'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 25),
              child: ListTile(
                title: const Text('logout'),
                leading: const Icon(Icons.logout),
                onTap: () => AuthService().signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
