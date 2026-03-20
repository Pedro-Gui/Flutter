
import 'package:flutter/widgets.dart';
import 'package:shop/pages/cart_page.dart';
import 'package:shop/pages/home_page.dart';
import 'package:shop/pages/intro_page.dart';
import 'package:shop/pages/shop_page.dart';


class Routes {
  static Map<String, Widget> routes = {
    '/introPage': IntroPage(),
    '/homePage': HomePage(),
    '/shopPage': ShopPage(),
    '/cartPage': CartPage(),
  };

  static Map<String, Widget> onlyShopRoutes = {
    '/shopPage': ShopPage(),
    '/cartPage': CartPage(),
  };
}
