import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'editProductScreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final priceFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final imageUrlController = TextEditingController();
  final imageUrlFocusNode = FocusNode();
  final form = GlobalKey<FormState>();
  bool loading = false;
  Product editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');

  bool isInit = true;
  var initValue = {'title': '', 'description': '', 'price': 0, 'imageUrl': ''};

  @override
  void initState() {
    // TODO: implement initState
    imageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  void updateImageUrl() {
    if (!imageUrlFocusNode.hasFocus) {
      if (imageUrlController.text.isEmpty ||
          (!imageUrlController.text.startsWith('http') &&
              !imageUrlController.text.startsWith('https')) ||
          (!imageUrlController.text.endsWith('png') &&
              !imageUrlController.text.endsWith('jpg') &&
              !imageUrlController.text.endsWith('jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> saveForm() async {
    final isValid = form.currentState.validate();
    if (!isValid) return;
    form.currentState.save();
    setState(() {
      loading = true;
    });
    if (editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(editedProduct.id, editedProduct);
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(editedProduct);
      } catch (e) {
        await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error Occurred'),
                  content: Text('Something Went Wrong'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
      } finally {
        setState(() {
          loading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        initValue = {
          'title': editedProduct.title,
          'price': editedProduct.price.toString(),
          'description': editedProduct.description,
          'imageUrl': '',
        };
        imageUrlController.text = editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveForm();
            },
          )
        ],
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: initValue['title'],
                      validator: (value) {
                        if (value.isEmpty) return 'Please Provide a Value';
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            title: value,
                            price: editedProduct.price,
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite);
                      },
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(priceFocusNode);
                      },
                    ),
                    TextFormField(
                      initialValue: initValue['price'].toString(),
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Price';
                        }
                        if (double.tryParse(value) == null)
                          return 'Please Enter a Valid Number';
                        if (double.parse(value) <= 0)
                          return 'Please Enter a Number Greater Than 0';
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            title: editedProduct.title,
                            price: double.parse(value),
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: initValue['description'],
                      focusNode: descriptionFocusNode,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value.isEmpty) return 'Please Enter a Description';
                        if (value.length < 10)
                          return 'Should be Greater than atlease 10 Characters';
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            title: editedProduct.title,
                            price: editedProduct.price,
                            description: value,
                            imageUrl: editedProduct.imageUrl,
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 8, right: 10),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: imageUrlController.text.isEmpty
                              ? Text('Enter a URL', textAlign: TextAlign.center)
                              : Image.network(
                                  imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image Url'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: imageUrlController,
                            focusNode: imageUrlFocusNode,
                            onFieldSubmitted: (value) {
                              saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter an image Url';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please Enter a Valid Url';
                              }
                              if (!value.endsWith('png') &&
                                  !value.endsWith('jpg') &&
                                  value.endsWith('jpeg'))
                                return 'Please Enter a Valid Image Url';
                              return null;
                            },
                            onSaved: (value) {
                              editedProduct = Product(
                                  title: editedProduct.title,
                                  price: editedProduct.price,
                                  description: editedProduct.description,
                                  imageUrl: value,
                                  id: editedProduct.id,
                                  isFavorite: editedProduct.isFavorite);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    priceFocusNode.dispose();
    descriptionFocusNode.dispose();
    imageUrlFocusNode.removeListener(updateImageUrl);
    imageUrlFocusNode.dispose();
    super.dispose();
  }
}
