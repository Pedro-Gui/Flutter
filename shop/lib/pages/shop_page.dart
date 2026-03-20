import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/components/shop_tile.dart';
import 'package:shop/pages/config/colors.dart';
import 'package:shop/pages/models/art.dart';
import 'package:shop/pages/models/cart.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {

  void onAdd2Cart(Art art) {
    Provider.of<Cart>(context, listen: false).addToCart(art);
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: SysColors.backgroundColor,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0), // Ajuste conforme o arredondamento atual
      side: BorderSide(
        color: SysColors.primaryColor, // Escolha a cor da borda aqui
        width: 4.0, // Espessura da linha
      ),
    ),
      title: Text('Art added to cart!'),
      content: Text('Art ${art.name} has been added to your cart.'),
     ));
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder:(context, value, child) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SysColors.softSecondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
                
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Search', style: TextStyle(fontSize: 16)),
                  Icon(Icons.search),
                ],
              ),
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            child: Text(
              'Unlock your sayajin power!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hot Picks 🔥',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14,
                    color: SysColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
      
          SizedBox(height: 10),
      
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: value.getArtsList().length,
              itemBuilder: (context, index) {
                Art art = value.getArtsList()[index];
                return ShopTile(
                  art: art,
                  onAdd2Cart: () => onAdd2Cart(art),
                );
              },
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
            child: Divider(color: SysColors.backgroundColor,),
          )
        ],
      ),
    );
  }
}
