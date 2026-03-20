import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/components/cart_item.dart';
import 'package:shop/pages/models/art.dart';
import 'package:shop/pages/models/cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Column(
      
        children: [

          Text('My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),),

          const SizedBox(height: 40,),
          Expanded(
            child: ListView.builder(
              itemCount: value.getPicekdItens().length,
              itemBuilder: (context, index) {
                Art art = value.getPicekdItens()[index];
                return CartItem(art: art);
              }) )
        ],
      ),
    );
  }
}