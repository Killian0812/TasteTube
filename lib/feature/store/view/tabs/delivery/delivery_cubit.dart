import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/order/delivery_options.dart';

abstract class DeliveryState {}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryLoaded extends DeliveryState {
  final DeliveryOptions options;
  DeliveryLoaded(this.options);
}

class DeliveryError extends DeliveryState {
  final String message;
  DeliveryError(this.message);
}

class DeliveryCubit extends Cubit<DeliveryState> {
  DeliveryCubit() : super(DeliveryInitial());

  void loadDeliveryOptions() {
    emit(DeliveryLoading());
    try {
      final options = DeliveryOptions(
        feePerKm: 0.5,
        minimumOrder: 10.0,
        maxDistance: 15.0,
        isActive: true,
        currency: 'USD', // Default currency
      );
      emit(DeliveryLoaded(options));
    } catch (e) {
      emit(DeliveryError('Failed to load delivery options'));
    }
  }

  void updateDeliveryOptions(DeliveryOptions newOptions) {
    emit(DeliveryLoading());
    try {
      emit(DeliveryLoaded(newOptions));
    } catch (e) {
      emit(DeliveryError('Failed to update delivery options'));
    }
  }
}
