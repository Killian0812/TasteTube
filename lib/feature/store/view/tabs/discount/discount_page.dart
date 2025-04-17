import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/view/tabs/discount/discount_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/product/product_cubit.dart';
import 'package:taste_tube/global_data/discount/discount.dart';
import 'package:taste_tube/global_data/product/product.dart';
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
                      BlocBuilder<ProductCubit, ProductState>(
                        builder: (context, state) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: discounts.length,
                            itemBuilder: (context, index) {
                              final discount = discounts[index];
                              final products = state.categorizedProducts.values
                                  .expand((list) => list)
                                  .toList();
                              final productNames = products
                                  .where(
                                      (e) => discount.productIds.contains(e.id))
                                  .map((e) => e.name)
                                  .toList()
                                  .join(', ');
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
                                          const Icon(Icons.calendar_month),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${discount.startDate != null ? DateFormat(_discountDateFormat).format(discount.startDate!) : "∞"} - ${discount.endDate != null ? DateFormat(_discountDateFormat).format(discount.endDate!) : "∞"}',
                                          ),
                                        ],
                                      ),
                                    if (discount.minOrderAmount != null)
                                      Text(
                                          'Min Order: ${discount.minOrderAmount} ${UserDataUtil.getCurrency()}'),
                                    if (discount.maxUses != null)
                                      Text('Max Uses: ${discount.maxUses}'),
                                    if (discount.usesPerUser != null)
                                      Text(
                                          'Uses Per User: ${discount.usesPerUser}'),
                                    if (productNames.isNotEmpty)
                                      Text('Products: $productNames',
                                          overflow: TextOverflow.ellipsis),
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
  final productCubit = context.read<ProductCubit>();
  showDialog(
    context: context,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: productCubit)
      ],
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
  late List<String> _selectedProductIds;
  late String _productSelectionType;
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
    _selectedProductIds = widget.discount?.productIds ?? [];
    _productSelectionType = _selectedProductIds.isEmpty ? 'entire' : 'specific';
    _startDate = widget.discount?.startDate ?? DateTime.now();
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

  Future<void> _selectProducts(
      BuildContext context, List<Product> products) async {
    final tempSelected = List<String>.from(_selectedProductIds);
    List<Product> filteredProducts = products;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: CommonSize.screenSize.height * 0.4,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  ListTile(
                    title: const Text('Select Products'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            this.setState(() {
                              _selectedProductIds = List.from(tempSelected);
                              _productSelectionType =
                                  _selectedProductIds.isEmpty
                                      ? 'entire'
                                      : 'specific';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search Products',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredProducts = products
                              .where((product) => product.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(child: Text('No products found'))
                        : ListView(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            children: filteredProducts.map((product) {
                              return CheckboxListTile(
                                title: Row(
                                  children: [
                                    product.images.isNotEmpty
                                        ? Image.network(
                                            product.images[0].url,
                                            width: 45,
                                            height: 45,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.broken_image,
                                              size: 45,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.image_not_supported,
                                            size: 45,
                                            color: Colors.grey,
                                          ),
                                    const SizedBox(width: 25),
                                    Expanded(
                                        child: Text(product.name,
                                            overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                value: tempSelected.contains(product.id),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      tempSelected.add(product.id);
                                    } else {
                                      tempSelected.remove(product.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  ({double value, String valueType}) _parseValueInput(
      String input, String selectedValueType) {
    input = input.trim();
    final value = double.tryParse(input) ?? 0.0;
    return (value: value, valueType: selectedValueType);
  }

  @override
  Widget build(BuildContext context) {
    final currency = UserDataUtil.getCurrency();
    final products = context
        .read<ProductCubit>()
        .state
        .categorizedProducts
        .values
        .expand((list) => list)
        .toList();
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
                  suffixIcon: PopupMenuButton<String>(
                    tooltip: 'Value type',
                    initialValue: _valueType,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'fixed',
                        child: Text(currency),
                      ),
                      const PopupMenuItem(
                        value: 'percentage',
                        child: Text('%'),
                      ),
                    ],
                    onSelected: (value) {
                      setState(() {
                        _valueType = value;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12.0),
                      child: Text(
                        _valueType == 'fixed' ? currency : '%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Apply To',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('Entire shop'),
                value: 'entire',
                groupValue: _productSelectionType,
                onChanged: (value) {
                  setState(() {
                    _productSelectionType = value!;
                    _selectedProductIds = [];
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Specific products'),
                value: 'specific',
                groupValue: _productSelectionType,
                onChanged: (value) {
                  setState(() {
                    _productSelectionType = value!;
                  });
                },
              ),
              if (_productSelectionType == 'specific')
                ExpansionTile(
                  trailing: IconButton(
                      onPressed: () => _selectProducts(context, products),
                      icon: Icon(Icons.edit)),
                  title: Text(
                    _selectedProductIds.isEmpty
                        ? 'No products selected'
                        : '${_selectedProductIds.length} product${_selectedProductIds.length == 1 ? '' : 's'} selected',
                  ),
                  children: products
                      .where((e) => _selectedProductIds.contains(e.id))
                      .map(
                        (e) => ListTile(
                          title: Row(
                            children: [
                              Image.network(
                                e.images[0].url,
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.broken_image,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 25),
                              Text(e.name, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      )
                      .toList(),
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
                        labelText: 'Start Date',
                        helperText: "",
                        border: OutlineInputBorder(),
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
                        labelText: 'End Date',
                        hintText: "Optional",
                        helperText: 'Leave blank for unlimited use time',
                        border: OutlineInputBorder(),
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
                        labelText: 'Max Uses',
                        hintText: "Optional",
                        helperText: 'Leave blank for unlimited total uses',
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
                        labelText: 'Uses Per User',
                        hintText: "Optional",
                        helperText: 'Leave blank for unlimited uses per user',
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
                  labelText: 'Minimum Order Amount',
                  hintText: "Optional",
                  helperText: 'Leave blank for all order uses',
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
              productIds: _selectedProductIds,
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
