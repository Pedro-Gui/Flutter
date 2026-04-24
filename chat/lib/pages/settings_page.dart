import 'package:chat/components/my_drawer.dart';
import 'package:chat/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const MyDrawer(),
      body: Center(
        child:Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Dark theme',
              ),
              trailing: CupertinoSwitch(
                value: Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).isDarkMode,
                onChanged: (value) => {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme(),
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}