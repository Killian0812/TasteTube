import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/view/tabs/voucher/voucher_cubit.dart';
import 'package:taste_tube/global_data/voucher/voucher.dart';
import 'package:taste_tube/utils/user_data.util.dart';
import 'package:intl/intl.dart';

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoucherCubit()..fetchVouchers(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<VoucherCubit, VoucherState>(
          listener: (context, state) {
            if (state is VoucherError) {
              ToastService.showToast(context, state.message, ToastType.error);
            }
            if (state is VoucherLoaded && state.message != null) {
              ToastService.showToast(
                  context, state.message!, ToastType.success);
            }
          },
          builder: (context, state) {
            if (state is VoucherLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VoucherLoaded) {
              return VoucherList(vouchers: state.vouchers);
            }
            if (state is VoucherError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<VoucherCubit>().fetchVouchers(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No vouchers available'));
          },
        ),
      ),
    );
  }
}

class VoucherList extends StatelessWidget {
  final List<Voucher> vouchers;

  const VoucherList({super.key, required this.vouchers});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<VoucherCubit>().fetchVouchers(),
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
                      'Vouchers',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (vouchers.isEmpty)
                      const Text('No vouchers found')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = vouchers[index];
                          return ListTile(
                            title: Text('Code: ${voucher.code}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Type: ${voucher.type.capitalize()} - Value: ${voucher.value}${voucher.type == "percentage" ? "%" : " ${UserDataUtil.getCurrency()}"}',
                                ),
                                Text(
                                  'Status: ${voucher.isActive ? "Active" : "Inactive"}',
                                ),
                                if (voucher.startDate != null)
                                  Text(
                                    'Start: ${DateFormat(_voucherDateFormat).format(voucher.startDate!)}',
                                  ),
                                if (voucher.endDate != null)
                                  Text(
                                    'End: ${DateFormat(_voucherDateFormat).format(voucher.endDate!)}',
                                  ),
                                if (voucher.minOrderAmount != null)
                                  Text(
                                    'Min Order: ${voucher.minOrderAmount} ${UserDataUtil.getCurrency()}',
                                  ),
                                if (voucher.maxUses != null)
                                  Text('Max Uses: ${voucher.maxUses}'),
                                if (voucher.usesPerUser != null)
                                  Text('Uses Per User: ${voucher.usesPerUser}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showVoucherForm(context, voucher: voucher);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final result = await showConfirmDialog(
                                      context,
                                      title:
                                          'Are you sure you want to delete voucher: ${voucher.code}?',
                                    );
                                    if (result == true && context.mounted) {
                                      context
                                          .read<VoucherCubit>()
                                          .deleteVoucher(voucher.id);
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
                      onPressed: () => showVoucherForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Voucher'),
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

void showVoucherForm(BuildContext context, {Voucher? voucher}) {
  final cubit = context.read<VoucherCubit>();
  showDialog(
    context: context,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: VoucherForm(voucher: voucher),
    ),
  );
}

class VoucherForm extends StatefulWidget {
  final Voucher? voucher;

  const VoucherForm({super.key, this.voucher});

  @override
  State<VoucherForm> createState() => _VoucherFormState();
}

class _VoucherFormState extends State<VoucherForm> {
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
    _codeController = TextEditingController(text: widget.voucher?.code ?? '');
    _valueController =
        TextEditingController(text: widget.voucher?.value.toString() ?? '');
    _maxUsesController =
        TextEditingController(text: widget.voucher?.maxUses?.toString() ?? '');
    _usesPerUserController = TextEditingController(
        text: widget.voucher?.usesPerUser?.toString() ?? '');
    _minOrderAmountController = TextEditingController(
        text: widget.voucher?.minOrderAmount?.toString() ?? '');
    _type = widget.voucher?.type ?? 'fixed';
    _isActive = widget.voucher?.isActive ?? true;
    _startDate = widget.voucher?.startDate;
    _endDate = widget.voucher?.endDate;
    _startDateController = TextEditingController(
        text: _startDate == null ? null : DateFormat(_voucherDateFormat).format(_startDate!));
    _endDateController = TextEditingController(
        text: _endDate == null ? null : DateFormat(_voucherDateFormat).format(_endDate!));
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
          _startDateController.text = DateFormat(_voucherDateFormat).format(_startDate!);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat(_voucherDateFormat).format(_endDate!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.voucher == null ? 'Add Voucher' : 'Edit Voucher'),
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
                readOnly: widget.voucher != null,
                decoration: InputDecoration(
                  labelText: 'Voucher Code',
                  border: const OutlineInputBorder(),
                  suffixIcon: widget.voucher == null
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
            final voucher = Voucher(
              id: widget.voucher?.id ?? '',
              shopId: UserDataUtil.getUserId(),
              code: _codeController.text.trim(),
              type: _type,
              value: double.tryParse(_valueController.text) ?? 0.0,
              description: widget.voucher?.description,
              startDate: _startDate,
              endDate: _endDate,
              isActive: _isActive,
              maxUses: int.tryParse(_maxUsesController.text),
              usesPerUser: int.tryParse(_usesPerUserController.text),
              minOrderAmount: double.tryParse(_minOrderAmountController.text),
              productIds: widget.voucher?.productIds ?? [],
              userUsedIds: widget.voucher?.userUsedIds ?? [],
            );

            if (voucher.code.isEmpty || voucher.value <= 0) {
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

            if (widget.voucher == null) {
              context.read<VoucherCubit>().createVoucher(voucher);
            } else {
              context.read<VoucherCubit>().updateVoucher(voucher.id, voucher);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

const _voucherDateFormat = 'dd/MM/yyyy';
