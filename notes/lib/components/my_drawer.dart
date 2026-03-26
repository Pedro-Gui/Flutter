import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/components/my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              // precisa disso para remover divider branco hard coded no DrawerHeader
              dividerTheme: const DividerThemeData(color: Colors.transparent),
            ),
            child: DrawerHeader(
              child: Center(
                child: Text(
                  'Notes',
                  style: GoogleFonts.dmSerifText(
                    fontSize: 48,
                    // fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25),

          MyDrawertile(
            icon: Icons.home,
            text: 'Home',
            onTap: ()=>{Navigator.pushNamed(context, '/notesPage')}
          ),

          MyDrawertile(
            icon: Icons.settings,
            text: 'Settings',
            onTap: ()=>{Navigator.pushNamed(context, '/settingPage')}
          ),

        ],
      ),
    );
  }
}
