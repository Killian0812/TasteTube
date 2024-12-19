part of 'payment_page.dart';

extension PaymentStateExt on State<PaymentPage> {
  void showAddressForm(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<AddressCubit>();
    final nameController = TextEditingController(text: '');
    final phoneController = TextEditingController(text: '');
    final valueController = TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Address"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(labelText: 'Receiver name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'Receiver phone'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a phone number' : null,
                ),
                TextFormField(
                  controller: valueController,
                  keyboardType: TextInputType.streetAddress,
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await cubit.addAddress(
                    nameController.text,
                    phoneController.text,
                    valueController.text,
                  );
                  if (context.mounted) Navigator.of(context).pop();
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
