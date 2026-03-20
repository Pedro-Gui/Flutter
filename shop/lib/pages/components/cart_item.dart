import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/config/colors.dart';
import 'package:shop/pages/models/art.dart';
import 'package:shop/pages/models/cart.dart';

// ignore: must_be_immutable
class CartItem extends StatefulWidget {
  Art art;
  CartItem({super.key, required this.art});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {

  void onRemoveItem() {
      Provider.of<Cart>(context, listen: false).removeFromCart(widget.art);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),

      decoration: BoxDecoration(
        color: SysColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SysColors.primaryColor,
          width: 2.0,
        ),
      ),

      child: ListTile(
        leading: Image.asset(widget.art.imagePath, width: 80, height: 100, fit: BoxFit.fitHeight),
        title: Text(widget.art.name),
        subtitle: Text(widget.art.price),
        trailing: IconButton(onPressed: onRemoveItem, icon: Icon(Icons.delete, color: SysColors.primaryColor,)),
      ),
    );
  }
}