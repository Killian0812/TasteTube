import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
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
            return DiscountList(discounts: state.discounts);
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
                            title: SelectableText('Code: ${discount.code}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Type: ${discount.type.capitalize()} - Value: ${discount.value}${discount.type == "percentage" ? "%" : " ${UserDataUtil.getCurrency()}"}',
                                ),
                                if (discount.startDate != null ||
                                    discount.endDate != null)
                                  Text(
                                    'Valid: ${discount.startDate != null ? DateFormat(_discountDateFormat).format(discount.startDate!) : "∞"} - ${discount.endDate != null ? DateFormat(_discountDateFormat).format(discount.endDate!) : "∞"}',
                                  ),
                                if (discount.minOrderAmount != null)
                                  Text(
                                    'Min Order: ${discount.minOrderAmount} ${UserDataUtil.getCurrency()}',
                                  ),
                                if (discount.maxUses != null)
                                  Text('Max Uses: ${discount.maxUses}'),
                                if (discount.usesPerUser != null)
                                  Text('Uses Per User: ${discount.usesPerUser}'),
                                Row(
                                  children: [
                                    Text('Status: '),
                                    Text(
                                      discount.isActive ? "Active" : "Inactive",
                                      style: TextStyle(
                                        color: discount.isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDiscountForm(context, discount: discount);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final result = await showConfirmDialog(
                                      context,
                                      title:
                                          'Are you sure you want to delete discount: ${discount.code}?',
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
  late TextEditingController _codeController;
  late TextEditingController _valueController;
  late TextEditingController _maxUsesController;
  late TextEditingController _usesPerUserController;
  late TextEditingController _minOrderAmountController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late String _type;
  late bool _isActive;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.discount?.code ?? '');
    _valueController =
        TextEditingController(text: widget.discount?.value.toString() ?? '');
    _maxUsesController =
        TextEditingController(text: widget.discount?.maxUses?.toString() ?? '');
    _usesPerUserController = TextEditingController(
        text: widget.discount?.usesPerUser?.toString() ?? '');
    _minOrderAmountController = TextEditingController(
        text: widget.discount?.minOrderAmount?.toString() ?? '');
    _type = widget.discount?.type ?? 'fixed';
    _isActive = widget.discount?.isActive ?? true;
    _startDate = widget.discount?.startDate;
    _endDate = widget.discount?.endDate;
    _startDateController = TextEditingController(
        text: _startDate == null
            ? null
            : DateFormat(_discountDateFormat).format(_startDate!));
    _endDateController = TextEditingController(
        text: _endDate == null
            ? null
            : DateFormat(_discountDateFormat).format(_endDate!));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _maxUsesController.dispose();
    _usesPerUserController.dispose();
    _minOrderAmountController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                controller: _codeController,
                readOnly: widget.discount != null,
                decoration: InputDecoration(
                  labelText: 'Discount Code',
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
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
                  DropdownMenuItem(
                      value: 'percentage', child: Text('Percentage')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Value',
                  suffixText:
                      _type == 'percentage' ? '%' : UserDataUtil.getCurrency(),
                  border: OutlineInputBorder(),
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
              TextField(
                controller: _maxUsesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Uses (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usesPerUserController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Uses Per User (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minOrderAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Minimum Order Amount (Optional)',
                  suffixText: UserDataUtil.getCurrency(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value!;
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
            final discount = Discount(
              id: widget.discount?.id ?? '',
              shopId: UserDataUtil.getUserId(),
              code: _codeController.text.trim(),
              type: _type,
              value: double.tryParse(_valueController.text) ?? 0.0,
              description: widget.discount?.description,
              startDate: _startDate,
              endDate: _endDate,
              isActive: _isActive,
              maxUses: int.tryParse(_maxUsesController.text),
              usesPerUser: int.tryParse(_usesPerUserController.text),
              minOrderAmount: double.tryParse(_minOrderAmountController.text),
              productIds: widget.discount?.productIds ?? [],
              userUsedIds: widget.discount?.userUsedIds ?? [],
            );

            if (discount.code.isEmpty || discount.value <= 0) {
              ToastService.showToast(
                context,
                'Please enter a valid code and value',
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
              context.read<DiscountCubit>().updateDiscount(discount.id, discount);
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
