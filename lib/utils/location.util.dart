import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/utils/user_data.util.dart';

Future<Position> locateCurrentPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition();
}

void pickLocationThenShowAddressForm(BuildContext context) {
  context.push("/location").then((location) {
    if (context.mounted && location is LocationResult) {
      showAddressForm(
        context,
        Address(
          name: "",
          phone: "",
          userId: UserDataUtil.getUserId(),
          value: location.formattedAddress!,
          latitude: location.latLng!.latitude,
          longitude: location.latLng!.longitude,
        ),
      );
    }
  });
}

void showAddressForm(BuildContext context, Address address) {
  final formKey = GlobalKey<FormState>();
  final cubit = context.read<AddressCubit>();
  final nameController = TextEditingController(text: address.name);
  final phoneController = TextEditingController(text: address.phone);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(address.id == null ? "Add Address" : "Edit Address"),
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
                decoration: const InputDecoration(labelText: 'Receiver phone'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              TextFormField(
                readOnly: true,
                initialValue: address.value,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(labelText: 'Address'),
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
                cubit.addOrUpdateAddress(
                  id: address.id,
                  name: nameController.text,
                  phone: phoneController.text,
                  value: address.value,
                  latitude: address.latitude,
                  longitude: address.longitude,
                );
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
