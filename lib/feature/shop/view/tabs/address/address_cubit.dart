import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/shop/domain/address_repo.dart';
import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/injection.dart';

abstract class AddressState {
  final List<Address> addresses;

  AddressState(this.addresses);
}

class AddressInitial extends AddressState {
  AddressInitial() : super([]);
}

class AddressLoading extends AddressState {
  AddressLoading(super.address);
}

class AddressLoaded extends AddressState {
  final List<Address> address;
  AddressLoaded(this.address) : super(address);
}

class AddressError extends AddressState {
  final List<Address> address;
  final String message;
  AddressError(this.address, this.message) : super(address);
}

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;

  AddressCubit()
      : repository = getIt<AddressRepository>(),
        super(AddressInitial());

  Future<void> fetchAddresses() async {
    emit(AddressLoading(state.addresses));
    try {
      final result = await repository.getAddresses();
      result.fold(
        (error) => emit(AddressError(
          state.addresses,
          error.message ?? 'Error fetching addresses',
        )),
        (addresses) => emit(AddressLoaded(addresses)),
      );
    } catch (e) {
      emit(AddressError(state.addresses, e.toString()));
    }
  }

  Future<void> addAddress(
    String name,
    String phone,
    String value,
  ) async {
    emit(AddressLoading(state.addresses));
    try {
      final result = await repository.addAddress(name, phone, value);
      result.fold(
        (error) => emit(AddressError(
          state.addresses,
          error.message ?? 'Failed to add address',
        )),
        (newAddress) {
          final updatedAddresses = [...state.addresses];
          updatedAddresses.add(newAddress);
          emit(AddressLoaded(updatedAddresses));
        },
      );
    } catch (e) {
      emit(AddressError(state.addresses, "Failed to add address"));
    }
  }

  Future<void> deleteAddress(Address address) async {
    emit(AddressLoading(state.addresses));
    try {
      final result = await repository.deleteAddress(address.id);
      result.fold(
        (error) => emit(AddressError(
          state.addresses,
          error.message ?? 'Failed to delete address',
        )),
        (success) {
          final updatedAddresses = [...state.addresses];
          updatedAddresses.removeWhere((e) => e.id == address.id);
          emit(AddressLoaded(updatedAddresses));
        },
      );
    } catch (e) {
      emit(AddressError(state.addresses, e.toString()));
    }
  }

  Future<void> updateAddress(
    String id,
    String name,
    String phone,
    String value,
  ) async {
    emit(AddressLoading(state.addresses));
    try {
      final result = await repository.updateAddress(id, name, phone, value);
      result.fold(
        (error) => emit(AddressError(
          state.addresses,
          error.message ?? 'Failed to update address',
        )),
        (newAddress) {
          final updatedAddresses = [...state.addresses];
          final index = updatedAddresses.indexWhere((e) => e.id == id);
          updatedAddresses[index] = newAddress;
          emit(AddressLoaded(updatedAddresses));
        },
      );
    } catch (e) {
      emit(AddressError(state.addresses, e.toString()));
    }
  }
}
