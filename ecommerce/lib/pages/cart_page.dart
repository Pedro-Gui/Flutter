import 'package:ecommerce/pages/components/my_button.dart';
import 'package:ecommerce/pages/components/my_drawer.dart';
import 'package:ecommerce/pages/models/product.dart';
import 'package:ecommerce/pages/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Shop>().cart;

    void removeItemFormCart(BuildContext context, Product product) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Remove item from cart ?'),
          actions: [
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.secondary,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Remove'),
              onPressed: () => {
                Navigator.pop(context),
                context.read<Shop>().removeFromCart(product),
              },
            ),
          ],
        ),
      );
    }

    void onPay(BuildContext context) {
      // 0.0 é o valor inicial da soma
      final totalValue = context.read<Shop>().cart.fold<double>(
        0.0,
        (previousValue, item) => previousValue + item.price,
      );
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Payment'),
          actions: [
            MaterialButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.secondary,
              child: Text(
                'Pay: \$${totalValue.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              onPressed: () => {Navigator.pop(context)},
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      drawer: MyDrawer(),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.price.toString()),
                        trailing: IconButton(
                          onPressed: () => removeItemFormCart(context, item),
                          icon: Icon(Icons.remove),
                        ),
                        leading: Container(
                          width: 60,
                          height: 60,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Image.asset(item.imagePath, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(25.0),
            child: MyButton(
              onTap: () => onPay(context),
              child: Text('Pay now'),
            ),
          ),
        ],
      ),
    );
  }
}
