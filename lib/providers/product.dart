import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title, description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite: false});

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url =
        'https://shop-app-30bb0.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    final oldFavoriteStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldFavoriteStatus;
        notifyListeners();
      }
    } catch (e) {
      isFavorite = oldFavoriteStatus;
      notifyListeners();
    }
  }
}
