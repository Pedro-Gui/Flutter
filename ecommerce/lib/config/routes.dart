import 'package:ecommerce/pages/cart_page.dart';
import 'package:ecommerce/pages/intro_page.dart';
import 'package:ecommerce/pages/shop_page.dart';
import 'package:flutter/widgets.dart';

class Routes {
  static Map<String, Widget> routes = {
    '/introPage': IntroPage(),
    '/shopPage': ShopPage(),
    '/cartPage': CartPage(),
  };

  static Map<String, Widget> onlyShopRoutes = {
    '/shopPage': ShopPage(),
    '/cartPage': CartPage(),
  };
}
