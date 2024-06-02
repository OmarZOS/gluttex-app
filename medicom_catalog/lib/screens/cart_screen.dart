import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/ProductService.dart';
import 'package:locator/locator.dart';
import 'package:medicom_catalog/screens/product_screen.dart';

class CartScreen extends StatelessWidget {
  // final List<Product> cartItems = []; // List of products added to the cart

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Cart'),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(
          Icons.done_outline_rounded,
          color: Colors.green,
        ),
      ),
      body: FutureBuilder(
          future: GluttexLocator.get<ProductService>().getAllProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError || snapshot.data!.isEmpty) {
                return Center(
                    child: Text(
                        'Error: ${snapshot.error ?? GluttexConstants.noProductsFound}'));
              }
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var product = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      // tileColor: Colors.blue[50],
                      leading: const Icon(Icons.food_bank_sharp),
                      title: Text('${product.product_name}'),
                      subtitle: Text('\$${product.id_product}'),
                      trailing:
                          // Text('\$${product.product_barcode}'),
                          IconButton(
                              onPressed: () => {
                                    // bool  = GluttexLocator.get<CartService>().deleteFromCart(product.id_product);
                                  },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              )),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              product: product,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
