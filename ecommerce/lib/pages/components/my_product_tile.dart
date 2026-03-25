import 'package:ecommerce/pages/models/product.dart';
import 'package:ecommerce/pages/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProductTile extends StatelessWidget {
  final Product product;
  const MyProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {

    void addProductTocart(BuildContext context, Product product){
      showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          content: Text('Add item to cart ?'),
          actions: [
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              onPressed: () => Navigator.pop(context)
              ),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Theme.of(context).colorScheme.secondary,
              child: Text('Add', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              onPressed: () => {Navigator.pop(context), context.read<Shop>().addToCart(product)} 
              ),
          ]
        ));
    
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: 12, left: 12, right: 12),
      padding: EdgeInsets.all(25),
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Image.asset(product.imagePath, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                product.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              const SizedBox(height: 10),

              Text(
                product.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.price.toString()),

              GestureDetector(
                onTap: () => addProductTocart(context, product),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                  ),
                  child:  Icon(Icons.add)
                  ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
