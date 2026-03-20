import 'package:flutter/material.dart';
import 'package:shop/pages/components/bottom_nav_bar.dart';
import 'package:shop/pages/config/colors.dart';
import 'package:shop/pages/config/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  void onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SysColors.backgroundColor,
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => onTabChange(index),
      ),

      appBar: AppBar(
        backgroundColor: SysColors.backgroundColor,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu, color: SysColors.primaryColor),
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: SysColors.darkBackgroundColor,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Theme(
              data: Theme.of(context).copyWith( // precisa disso para remover divider branco hard coded no DrawerHeader
                dividerTheme: const DividerThemeData(color: Colors.transparent),
              ),
              child: DrawerHeader(
                decoration: BoxDecoration(color: SysColors.darkBackgroundColor),
                child: Image.asset('lib/images/logo.png'),
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Divider(color: SysColors.darkGrey),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: ListTile(
                leading: Icon(
                  Icons.home,
                  color: SysColors.primaryColor,
                ),
                title: Text(
                  'Home',
                  style: TextStyle(color: SysColors.primaryColor),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: ListTile(
                leading: Icon(
                  Icons.info,
                  color: SysColors.primaryColor,
                ),
                title: Text(
                  'About',
                  style: TextStyle(color: SysColors.primaryColor),
                ),
              ),
            )

              ]),
            
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 50.0),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: SysColors.primaryColor,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(color: SysColors.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Routes.onlyShopRoutes.values.elementAt(_selectedIndex),
    );
  }
}
