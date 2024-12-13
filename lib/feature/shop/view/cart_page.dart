import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () {
          context.push('/cart');
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Align(
                alignment: Alignment.center,
                child: Icon(Icons.shopping_cart, size: 35)),
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state.cart.items.isEmpty) return const SizedBox.shrink();
                return Container(
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
                  child: Center(
                      child: Text(
                    state.cart.items.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                  "Cart (${state.cart.items.isEmpty ? 'Empty' : state.cart.items.length.toString()})"),
            ),
            body: TextButton(
              onPressed: () async {
                await context.read<OrderCubit>().getCart();
              },
              child: const Text("CLICK"),
            ));
      },
    );
  }
}
