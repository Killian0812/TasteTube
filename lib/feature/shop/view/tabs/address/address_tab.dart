import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/utils/location/location.util.dart';

class AddressTab extends StatelessWidget {
  const AddressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ToastService.showToast(context, state.message, ToastType.warning);
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AddressCubit>().fetchAddresses();
            },
            child: ListView.builder(
              itemCount: state.addresses.length,
              itemBuilder: (context, index) {
                final address = state.addresses[index];
                return ListTile(
                  title: Text('${address.name} - ${address.phone}'),
                  subtitle: Text('Address: ${address.value}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showAddressForm(context, address);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final result = await showConfirmDialog(context,
                              title:
                                  "Are you sure to remove address: ${address.value}?");
                          if (result != true) return;
                          if (context.mounted) {
                            context.read<AddressCubit>().deleteAddress(address);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add new address'),
        icon: const Icon(Icons.add_location_alt),
        onPressed: () => pickLocationThenShowAddressForm(context),
      ),
    );
  }
}
