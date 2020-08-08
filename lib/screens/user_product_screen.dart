import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/userProducts';

  Future<void> refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context,listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
//    final productsItem = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: refreshProducts(context),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () => refreshProducts(context),
                  child: Consumer<Products>(
                    builder:
                        (context, productsItem,child) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Column(
                              children: <Widget>[
                                UserProductItem(
                                    productsItem.items[index].title,
                                    productsItem.items[index].imageUrl,
                                    productsItem.items[index].id),
                                Divider(),
                              ],
                            );
                          },
                          itemCount: productsItem.items.length,
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
