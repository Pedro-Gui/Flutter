import 'package:ecommerce/pages/models/product.dart';
import 'package:flutter/material.dart';

class Shop extends ChangeNotifier{
  final List<Product> _shop = [
    Product(name: 'Nike Shox', price: 600.00, description: 'Branco com verde', imagePath: 'lib/pages/images/nikeShox.png'),
    Product(name: 'Adidas ultraboost', price: 800.00, description: 'Night blue, extra soft', imagePath: 'lib/pages/images/ultraboost.png'),
    Product(name: 'Galaxy Buds FE', price: 300.00, description: 'Clear audio, white, noise cancel', imagePath: 'lib/pages/images/budsFE.png'),
    Product(name: 'Galaxy S25 FE', price: 2900.00, description: 'Blue, 128GB, Galaxy AI', imagePath: 'lib/pages/images/s25FE.png'),
    Product(name: 'Galaxy Watch 7', price: 1100.00, description: 'Galaxy watch new generation', imagePath: 'lib/pages/images/galaxywatch7.png'),
  ];

  List<Product> _cart = [];

  List<Product> get shop => _shop;

  List<Product> get cart => _cart;

  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.remove(product);
    notifyListeners();
  }

  

}