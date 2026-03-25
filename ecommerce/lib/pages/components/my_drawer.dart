import 'package:ecommerce/pages/components/my_drawer_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  // precisa disso para remover divider branco hard coded no DrawerHeader
                  dividerTheme: const DividerThemeData(
                    color: Colors.transparent,
                  ),
                ),
                child: DrawerHeader(
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 72,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              MyDrawertile(
                icon: Icons.home,
                text: 'Home',
                onTap: () => Navigator.pushNamed(context, '/shopPage'),
              ),
              
              MyDrawertile(
                icon: Icons.shopping_cart,
                text: 'Cart',
                onTap: () => Navigator.pushNamed(context, '/cartPage'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only( bottom: 25.0),
            child: MyDrawertile(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/introPage', (route) => false),
            ),
          ),
        ],
      ),
    );
  }
}
