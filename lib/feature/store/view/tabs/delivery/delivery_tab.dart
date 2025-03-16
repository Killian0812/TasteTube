import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/view/tabs/delivery/delivery_cubit.dart';
import 'package:taste_tube/global_data/order/delivery_options.dart';

class DeliveryTab extends StatelessWidget {
  const DeliveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryCubit()..loadDeliveryOptions(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<DeliveryCubit, DeliveryState>(
          listener: (context, state) {
            if (state is DeliveryError) {
              ToastService.showToast(context, state.message, ToastType.error);
            }
          },
          builder: (context, state) {
            if (state is DeliveryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DeliveryLoaded) {
              return DeliveryForm(options: state.options);
            }
            return const Center(child: Text('Please wait...'));
          },
        ),
      ),
    );
  }
}

class DeliveryForm extends StatefulWidget {
  final DeliveryOptions options;

  const DeliveryForm({super.key, required this.options});

  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  late TextEditingController _feeController;
  late TextEditingController _minimumController;
  late TextEditingController _distanceController;
  late bool _isActive;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _feeController =
        TextEditingController(text: widget.options.feePerKm.toString());
    _minimumController =
        TextEditingController(text: widget.options.minimumOrder.toString());
    _distanceController =
        TextEditingController(text: widget.options.maxDistance.toString());
    _isActive = widget.options.isActive;
    _selectedCurrency = widget.options.currency;
  }

  @override
  void dispose() {
    _feeController.dispose();
    _minimumController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _feeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Delivery Fee per KM',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        items: ['USD', 'VND'].map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('/km'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minimumController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Minimum Order Amount',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        items: ['USD', 'VND'].map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _distanceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Maximum Delivery Distance',
                      suffixText: 'km',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    child: Text('Save Changes'),
                    onPressed: () {
                      final newOptions = DeliveryOptions(
                        feePerKm: double.tryParse(_feeController.text) ??
                            widget.options.feePerKm,
                        minimumOrder:
                            double.tryParse(_minimumController.text) ??
                                widget.options.minimumOrder,
                        maxDistance:
                            double.tryParse(_distanceController.text) ??
                                widget.options.maxDistance,
                        isActive: _isActive,
                        currency: _selectedCurrency,
                      );
                      context
                          .read<DeliveryCubit>()
                          .updateDeliveryOptions(newOptions);
                      ToastService.showToast(
                        context,
                        'Delivery settings updated successfully',
                        ToastType.success,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
