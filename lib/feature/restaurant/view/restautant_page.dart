import 'package:flutter/material.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(counter.toString()),
      FloatingActionButton(onPressed: () {
        setState(() {
          counter++;
        });
      }),
    ]));
  }
}
