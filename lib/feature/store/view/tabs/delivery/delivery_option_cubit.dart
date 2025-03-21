import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/store/data/delivery_options.dart';
import 'package:taste_tube/feature/store/domain/delivery_option_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class DeliveryOptionState {}

class DeliveryOptionInitial extends DeliveryOptionState {}

class DeliveryOptionLoading extends DeliveryOptionState {}

class DeliveryOptionLoaded extends DeliveryOptionState {
  final DeliveryOption option;
  final String? message;

  DeliveryOptionLoaded(this.option, {this.message});
}

class DeliveryError extends DeliveryOptionState {
  final String message;
  DeliveryError(this.message);
}

class DeliveryOptionCubit extends Cubit<DeliveryOptionState> {
  final DeliveryOptionRepository repository = getIt<DeliveryOptionRepository>();

  DeliveryOptionCubit() : super(DeliveryOptionInitial());

  Future<void> loadDeliveryOptions() async {
    emit(DeliveryOptionLoading());
    final result = await repository.getDeliveryOptions();
    result.fold(
      (error) =>
          emit(DeliveryError(error.message ?? 'Error loading delivery option')),
      (option) => emit(DeliveryOptionLoaded(option)),
    );
  }

  Future<void> updateDeliveryOptions(DeliveryOption newOptions) async {
    emit(DeliveryOptionLoading());
    final result = await repository.updateDeliveryOptions(newOptions);
    result.fold(
      (error) => emit(
          DeliveryError(error.message ?? 'Error updating delivery option')),
      (updatedOptions) => emit(DeliveryOptionLoaded(
        updatedOptions,
        message: 'Delivery settings updated successfully',
      )),
    );
  }
}
