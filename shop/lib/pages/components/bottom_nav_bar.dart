import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shop/pages/config/colors.dart';

// ignore: must_be_immutable
class BottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  BottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: GNav(
        color: SysColors.softGrey,
        activeColor: SysColors.primaryColor,
        mainAxisAlignment: MainAxisAlignment.center,
       // tabActiveBorder: Border.all(color: SysColors.primaryColor, width: 1.5),
        tabBackgroundColor: Color.lerp(SysColors.backgroundColor, SysColors.primaryAccentColor, 0.3)!,//efeito .shade
        tabBorderRadius: 12,

        onTabChange: (value) => onTabChange!(value),
        tabs:const [
          GButton(
            icon: Icons.home,
             text: 'Shop'
             ),
          GButton(
            icon: Icons.shopping_bag_rounded, 
            text: 'Cart'
            ),
          /* GButton(
            icon: Icons.person,
             text: 'Profile'
             ), */
      ]),
    );
  }
}