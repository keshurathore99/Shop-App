import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFav = false;
  bool isInit = true, loading = false;

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        loading = true;
      });
      Provider.of<Products>(context)
          .fetchAndSetProducts()
          .then((_) {
        setState(() {
          loading = false;
        });
      });
    }
    setState(() {
      isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == FilterOptions.Favorites) {
                  _showOnlyFav = true;
                } else {
                  _showOnlyFav = false;
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: const Text('Favorite'),
                  value: FilterOptions.Favorites,
                ),
                PopupMenuItem(
                  child: const Text('Show All'),
                  value: FilterOptions.All,
                ),
              ];
            },
          ),
          Consumer<Cart>(
            builder: (_, cart, Widget child) => Badge(
              value: cart.itemCount.toString(),
              child: child,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.cartScreenRoute);
              },
            ),
          ),
        ],
        title: const Text('Shop App'),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFav),
      drawer: AppDrawer(),
    );
  }
}

enum FilterOptions { Favorites, All }
