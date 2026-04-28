import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/services/mongo_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final mongoService = Provider.of<MongoService>(context, listen: false);
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.list_outlined,
                  size: 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25,),
                  child: ListTile(
                    title: const Text('Home'),
                    leading: const Icon(Icons.home),
                    onTap: () => Navigator.pushNamed(context, '/homePage'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Profile'),
                    leading: const Icon(Icons.person),
                    onTap: () => Navigator.pushNamed(context, '/profilePage'),
                  ),
                ),
                ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 25),
              child: ListTile(
                title: const Text('logout'),
                leading: const Icon(Icons.logout),
                onTap: () => mongoService.signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
