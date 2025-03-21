import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/feature/store/data/delivery_options.dart';
import 'package:taste_tube/feature/store/view/tabs/delivery/delivery_option_cubit.dart';
import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/utils/location/location.util.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class DeliveryOptionTab extends StatelessWidget {
  const DeliveryOptionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DeliveryOptionCubit()..loadDeliveryOptions(),
        ),
        BlocProvider(
          create: (context) => AddressCubit()..fetchAddresses(),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<DeliveryOptionCubit, DeliveryOptionState>(
          listener: (context, state) {
            if (state is DeliveryError) {
              ToastService.showToast(context, state.message, ToastType.error);
            }
            if (state is DeliveryOptionLoaded && state.message != null) {
              ToastService.showToast(
                  context, state.message!, ToastType.success);
            }
          },
          builder: (context, deliveryState) {
            if (deliveryState is DeliveryOptionLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (deliveryState is DeliveryOptionLoaded) {
              return BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, addressState) {
                if (addressState is AddressLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return DeliveryForm(
                  option: deliveryState.option,
                  addresses: addressState.addresses,
                );
              });
            }
            return const Center(child: Text('Please wait...'));
          },
        ),
      ),
    );
  }
}

class DeliveryForm extends StatefulWidget {
  final DeliveryOption option;
  final List<Address> addresses;

  const DeliveryForm({
    super.key,
    required this.option,
    required this.addresses,
  });

  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  late TextEditingController _feeController;
  late TextEditingController _distanceController;
  late TextEditingController _freeDistanceController;
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _feeController =
        TextEditingController(text: widget.option.feePerKm.toString());
    _distanceController =
        TextEditingController(text: widget.option.maxDistance.toString());
    _freeDistanceController =
        TextEditingController(text: widget.option.freeDistance.toString());
    _selectedAddress = widget.addresses.firstWhereOrNull(
      (e) => e.value == widget.option.address?.value,
    );
  }

  @override
  void dispose() {
    _feeController.dispose();
    _distanceController.dispose();
    _freeDistanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<AddressCubit>().fetchAddresses(),
          context.read<DeliveryOptionCubit>().loadDeliveryOptions(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _freeDistanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Free Delivery Distance',
                        suffixText: 'Km',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _feeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Delivery Fee per KM',
                        suffixText: "${UserDataUtil.getCurrency()} / Km",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _distanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Maximum Delivery Distance',
                        suffixText: 'Km',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<Address>(
                      value: _selectedAddress,
                      hint: const Text('Select Delivery Address'),
                      isExpanded: true,
                      items: widget.addresses.map((address) {
                        return DropdownMenuItem<Address>(
                          value: address,
                          child: Text(
                            address.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (Address? newAddress) {
                        setState(() {
                          _selectedAddress = newAddress;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final newOption = DeliveryOption(
                          shopId: widget.option.shopId,
                          freeDistance:
                              double.tryParse(_freeDistanceController.text) ??
                                  widget.option.freeDistance,
                          feePerKm: double.tryParse(_feeController.text) ??
                              widget.option.feePerKm,
                          maxDistance:
                              double.tryParse(_distanceController.text) ??
                                  widget.option.maxDistance,
                          address: _selectedAddress, // Use selected address
                        );
                        context
                            .read<DeliveryOptionCubit>()
                            .updateDeliveryOptions(newOption);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Address Management Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Addresses',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (widget.addresses.isEmpty)
                      const Text('No addresses found')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.addresses.length,
                        itemBuilder: (context, index) {
                          final address = widget.addresses[index];
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
                                    final result = await showConfirmDialog(
                                      context,
                                      title:
                                          "Are you sure to remove address: ${address.value}?",
                                    );
                                    if (result != true) return;
                                    if (context.mounted) {
                                      context
                                          .read<AddressCubit>()
                                          .deleteAddress(address);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => pickLocationThenShowAddressForm(context),
                      icon: const Icon(Icons.add_location_alt),
                      label: const Text('Add New Address'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
