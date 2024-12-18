import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/global_data/order/address.dart';

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
                  title: Text(address.name),
                  subtitle: Text(address.value),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showAddressForm(context, address: address);
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
        icon: const Icon(Icons.place),
        onPressed: () => _showAddressForm(context),
      ),
    );
  }

  void _showAddressForm(BuildContext context, {Address? address}) {
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<AddressCubit>();
    final nameController = TextEditingController(text: address?.name ?? '');
    final phoneController = TextEditingController(text: address?.phone ?? '');
    final valueController = TextEditingController(text: address?.value ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(address == null ? "Add Address" : "Edit Address"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Receiver name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Receiver phone'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a phone number' : null,
                ),
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an address' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (address == null) {
                    cubit.addAddress(
                      nameController.text,
                      phoneController.text,
                      valueController.text,
                    );
                  } else {
                    cubit.updateAddress(
                      address.id,
                      nameController.text,
                      phoneController.text,
                      valueController.text,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
