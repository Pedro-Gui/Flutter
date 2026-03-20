import 'package:flutter/material.dart';
import 'package:shop/pages/models/art.dart';

class Cart extends ChangeNotifier {
  List<Art> items = [
    Art(
      name: 'Basic',
      price: '50',
      imagePath: 'lib/images/base.png',
      description: 'Forma base - Goku',
    ),
    Art(
      name: 'SSJ 1',
      price: '100',
      imagePath: 'lib/images/ssj1.png',
      description: 'Super Sayajin 1 - Goku',
    ),
    Art(
      name: 'SSJ 2',
      price: '200',
      imagePath: 'lib/images/ssj2.png',
      description: 'Super Sayajin 2 - Goku',
    ),
    Art(
      name: 'SSJ 3',
      price: '300',
      imagePath: 'lib/images/ssj3.png',
      description: 'Super Sayajin 3 - Goku',
    ),
    Art(
      name: 'SSJ 4',
      price: '400',
      imagePath: 'lib/images/ssj4.png',
      description: 'Super Sayajin 4 - Goku',
    ),
    Art(
      name: 'Gogeta SSJ 4',
      price: '100',
      imagePath: 'lib/images/gogeta-ssj4.png',
      description: 'Super Sayajin 4 - Gogeta',
    ),
  ];

  List<Art> pickedItens = [];

  List<Art> getArtsList() {
    return items;
  }

  List<Art> getPicekdItens() {
    return pickedItens;
  }

  void addToCart(Art art) {
    pickedItens.add(art);
    notifyListeners();
  }

  void removeFromCart(Art art) {
    pickedItens.remove(art);
    notifyListeners();
  } 
}
