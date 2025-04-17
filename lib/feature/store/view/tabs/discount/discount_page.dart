import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/view/tabs/discount/discount_cubit.dart';
import 'package:taste_tube/global_data/discount/discount.dart';
import 'package:taste_tube/utils/user_data.util.dart';
import 'package:intl/intl.dart';

class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscountCubit()..fetchDiscounts(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<DiscountCubit, DiscountState>(
          listener: (context, state) {
            if (state is DiscountError) {
              ToastService.showToast(context, state.message, ToastType.error);
            }
            if (state is DiscountLoaded && state.message != null) {
              ToastService.showToast(
                  context, state.message!, ToastType.success);
            }
          },
          builder: (context, state) {
            if (state is DiscountLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DiscountLoaded) {
              return DiscountList(discounts: state.discounts);
            }
            if (state is DiscountError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<DiscountCubit>().fetchDiscounts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No discounts available'));
          },
        ),
      ),
    );
  }
}

class DiscountList extends StatelessWidget {
  final List<Discount> discounts;

  const DiscountList({super.key, required this.discounts});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DiscountCubit>().fetchDiscounts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discounts',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (discounts.isEmpty)
                      const Text('No discounts found')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: discounts.length,
                        itemBuilder: (context, index) {
                          final discount = discounts[index];
                          return ListTile(
                            title: Text(discount.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (discount.code != null)
                                  Text('Coupon Code: ${discount.code}'),
                                Text(
                                  'Type: ${discount.type.toUpperCase()} - Value: ${discount.value}${discount.valueType == "percentage" ? "%" : " ${UserDataUtil.getCurrency()}"}',
                                ),
                                if (discount.startDate != null ||
                                    discount.endDate != null)
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month),
                                      SizedBox(width: 4),
                                      Text(
                                        '${discount.startDate != null ? DateFormat(_discountDateFormat).format(discount.startDate!) : "∞"} - ${discount.endDate != null ? DateFormat(_discountDateFormat).format(discount.endDate!) : "∞"}',
                                      ),
                                    ],
                                  ),
                                if (discount.minOrderAmount != null)
                                  Text(
                                    'Min Order: ${discount.minOrderAmount} ${UserDataUtil.getCurrency()}',
                                  ),
                                if (discount.maxUses != null)
                                  Text('Max Uses: ${discount.maxUses}'),
                                if (discount.usesPerUser != null)
                                  Text(
                                      'Uses Per User: ${discount.usesPerUser}'),
                                Text(
                                  'Status: ${discount.status.toUpperCase()}',
                                  style: TextStyle(
                                    color: discount.status == "active"
                                        ? Colors.green
                                        : discount.status == "inactive"
                                            ? Colors.red
                                            : Colors.yellow,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDiscountForm(context,
                                        discount: discount);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final result = await showConfirmDialog(
                                      context,
                                      title:
                                          'Are you sure you want to delete discount: ${discount.name}?',
                                    );
                                    if (result == true && context.mounted) {
                                      context
                                          .read<DiscountCubit>()
                                          .deleteDiscount(discount.id);
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
                      onPressed: () => showDiscountForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Discount'),
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

void showDiscountForm(BuildContext context, {Discount? discount}) {
  final cubit = context.read<DiscountCubit>();
  showDialog(
    context: context,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: DiscountForm(discount: discount),
    ),
  );
}

class DiscountForm extends StatefulWidget {
  final Discount? discount;

  const DiscountForm({super.key, this.discount});

  @override
  State<DiscountForm> createState() => _DiscountFormState();
}

class _DiscountFormState extends State<DiscountForm> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _valueController;
  late TextEditingController _maxUsesController;
  late TextEditingController _usesPerUserController;
  late TextEditingController _minOrderAmountController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late String _type;
  late String _valueType;
  late String _status;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.discount?.name ?? '');
    _codeController = TextEditingController(text: widget.discount?.code ?? '');
    _valueController = TextEditingController(
      text: widget.discount != null ? widget.discount!.value.toString() : '',
    );
    _maxUsesController =
        TextEditingController(text: widget.discount?.maxUses?.toString() ?? '');
    _usesPerUserController = TextEditingController(
        text: widget.discount?.usesPerUser?.toString() ?? '');
    _minOrderAmountController = TextEditingController(
        text: widget.discount?.minOrderAmount?.toString() ?? '');
    _type = widget.discount?.type ?? 'voucher';
    _valueType = widget.discount?.valueType ?? 'fixed';
    _status = widget.discount?.status == 'expired'
        ? 'inactive'
        : (widget.discount?.status ?? 'active');
    _startDate = widget.discount?.startDate;
    _endDate = widget.discount?.endDate;
    _startDateController = TextEditingController(
      text: _startDate == null
          ? ''
          : DateFormat(_discountDateFormat).format(_startDate!),
    );
    _endDateController = TextEditingController(
      text: _endDate == null
          ? ''
          : DateFormat(_discountDateFormat).format(_endDate!),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _valueController.dispose();
    _maxUsesController.dispose();
    _usesPerUserController.dispose();
    _minOrderAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _generateRandomCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text =
              DateFormat(_discountDateFormat).format(_startDate!);
        } else {
          _endDate = picked;
          _endDateController.text =
              DateFormat(_discountDateFormat).format(_endDate!);
        }
      });
    }
  }

  ({double value, String valueType}) _parseValueInput(
      String input, String selectedValueType) {
    input = input.trim();
    final value = double.tryParse(input) ?? 0.0;
    if (selectedValueType == 'percentage' && (value < 0 || value > 100)) {
      return (value: value, valueType: 'percentage');
    }
    return (value: value, valueType: selectedValueType);
  }

  @override
  Widget build(BuildContext context) {
    final currency = UserDataUtil.getCurrency();
    return AlertDialog(
      title: Text(widget.discount == null ? 'Add Discount' : 'Edit Discount'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.5,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Discount Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Discount Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Voucher'),
                      value: 'voucher',
                      groupValue: _type,
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                          if (_type != 'coupon') {
                            _codeController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Coupon'),
                      value: 'coupon',
                      groupValue: _type,
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (_type == 'coupon') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  readOnly: widget.discount != null,
                  decoration: InputDecoration(
                    labelText: 'Coupon Code',
                    border: const OutlineInputBorder(),
                    suffixIcon: widget.discount == null
                        ? IconButton(
                            icon: const Icon(Icons.shuffle),
                            tooltip: 'Random Code',
                            onPressed: () {
                              setState(() {
                                _codeController.text = _generateRandomCode();
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Value',
                  border: const OutlineInputBorder(),
                  suffixIcon: DropdownButton<String>(
                    value: _valueType,
                    items: [
                      DropdownMenuItem(value: 'fixed', child: Text(currency)),
                      const DropdownMenuItem(
                          value: 'percentage', child: Text('%')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _valueType = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: _startDateController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, true),
                        ),
                        labelText: 'Start Date (Optional)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: _endDateController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, false),
                        ),
                        labelText: 'End Date (Optional)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _maxUsesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Uses (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _usesPerUserController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Uses Per User (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minOrderAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Minimum Order Amount (Optional)',
                  suffixText: UserDataUtil.getCurrency(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _status == 'active',
                onChanged: (value) {
                  setState(() {
                    _status = value ? 'active' : 'inactive';
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final valueInput =
                _parseValueInput(_valueController.text, _valueType);
            final discount = Discount(
              id: widget.discount?.id ?? '',
              shopId: UserDataUtil.getUserId(),
              name: _nameController.text.trim(),
              code: _type == 'coupon' ? _codeController.text.trim() : null,
              type: _type,
              value: valueInput.value,
              valueType: valueInput.valueType,
              description: widget.discount?.description,
              startDate: _startDate,
              endDate: _endDate,
              status: _status,
              maxUses: int.tryParse(_maxUsesController.text),
              usesPerUser: int.tryParse(_usesPerUserController.text),
              minOrderAmount: double.tryParse(_minOrderAmountController.text),
              productIds: widget.discount?.productIds ?? [],
              userUsedIds: widget.discount?.userUsedIds ?? [],
            );

            if (discount.name.isEmpty) {
              ToastService.showToast(
                context,
                'Please enter a discount name',
                ToastType.warning,
              );
              return;
            }
            if (discount.type == 'coupon' &&
                (discount.code == null || discount.code!.isEmpty)) {
              ToastService.showToast(
                context,
                'Please enter a coupon code',
                ToastType.warning,
              );
              return;
            }
            if (discount.value <= 0) {
              ToastService.showToast(
                context,
                'Please enter a valid value',
                ToastType.warning,
              );
              return;
            }
            if (discount.valueType == 'percentage' &&
                (discount.value < 0 || discount.value > 100)) {
              ToastService.showToast(
                context,
                'Percentage value must be between 0 and 100',
                ToastType.warning,
              );
              return;
            }
            if (_startDate != null &&
                _endDate != null &&
                _startDate!.isAfter(_endDate!)) {
              ToastService.showToast(
                context,
                'Start date must be before end date',
                ToastType.warning,
              );
              return;
            }

            if (widget.discount == null) {
              context.read<DiscountCubit>().createDiscount(discount);
            } else {
              context
                  .read<DiscountCubit>()
                  .updateDiscount(discount.id, discount);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

const _discountDateFormat = 'dd/MM/yyyy';
