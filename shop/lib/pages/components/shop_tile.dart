import 'package:flutter/material.dart';
import 'package:shop/pages/config/colors.dart';
import 'package:shop/pages/models/art.dart';

// ignore: must_be_immutable
class ShopTile extends StatelessWidget {
  Art art;
  void Function()? onAdd2Cart;
  ShopTile({super.key, required this.art, required this.onAdd2Cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 25),
      width: 280,
      decoration: BoxDecoration(
        color: SysColors.softSecondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SysColors.primaryColor,
          width: 4.0,
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
            child: Image.asset(
              art.imagePath, 
              width: 300, 
              height: 400,
              fit: BoxFit.fitHeight,),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              art.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SysColors.darkGrey,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      art.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),),
                    SizedBox(height: 5),
                     Text(
                      '\$ ${art.price}',
                      style: TextStyle(                      
                        color: SysColors.grey,
                      ),)]
                  ),
              ),
              GestureDetector(
                onTap: onAdd2Cart,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SysColors.primaryColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(8)),
                  ),
                  child: Icon(Icons.add, color: SysColors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
