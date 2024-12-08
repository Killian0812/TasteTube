import 'package:flutter/material.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Align(
              alignment: Alignment.center,
              child: Icon(Icons.shopping_cart, size: 35)),
          Container(
            margin: const EdgeInsets.only(bottom: 20, left: 25),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: const Center(
              child: Text(
                '3', // TODO: Replace with the actual number of items
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
