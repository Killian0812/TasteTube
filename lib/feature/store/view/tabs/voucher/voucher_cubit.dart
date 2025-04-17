import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/feature/store/domain/voucher_repo.dart';
import 'package:taste_tube/global_data/voucher/voucher.dart';
import 'package:taste_tube/utils/user_data.util.dart';

abstract class VoucherState {
  final List<Voucher> vouchers;
  VoucherState({required this.vouchers});
}

class VoucherInitial extends VoucherState {
  VoucherInitial({required super.vouchers});
}

class VoucherLoading extends VoucherState {
  VoucherLoading({required super.vouchers});
}

class VoucherLoaded extends VoucherState {
  final String? message;

  VoucherLoaded(List<Voucher> vouchers, {this.message})
      : super(vouchers: vouchers);
}

class VoucherError extends VoucherState {
  final String message;

  VoucherError(List<Voucher> vouchers, this.message)
      : super(vouchers: vouchers);
}

class VoucherCubit extends Cubit<VoucherState> {
  final VoucherRepository repository = getIt<VoucherRepository>();

  VoucherCubit() : super(VoucherInitial(vouchers: []));

  Future<void> fetchVouchers() async {
    emit(VoucherLoading(vouchers: state.vouchers));
    final shopId = UserDataUtil.getUserId();
    final result = await repository.fetchVouchers(shopId);
    result.fold(
      (error) => emit(VoucherError(
          state.vouchers, error.message ?? 'Error loading vouchers')),
      (vouchers) => emit(VoucherLoaded(vouchers)),
    );
  }

  Future<void> createVoucher(Voucher voucher) async {
    emit(VoucherLoading(vouchers: state.vouchers));
    final result = await repository.createVoucher(voucher);
    result.fold(
      (error) => emit(VoucherError(
          state.vouchers, error.message ?? 'Error creating voucher')),
      (createdVoucher) async {
        await fetchVouchers(); // Refresh voucher list
        emit(VoucherLoaded(
          (state as VoucherLoaded?)?.vouchers ?? [],
          message: 'Voucher created successfully',
        ));
      },
    );
  }

  Future<void> updateVoucher(String voucherId, Voucher voucher) async {
    emit(VoucherLoading(vouchers: state.vouchers));
    final result = await repository.updateVoucher(voucherId, voucher);
    result.fold(
      (error) => emit(VoucherError(
          state.vouchers, error.message ?? 'Error updating voucher')),
      (updatedVoucher) async {
        await fetchVouchers(); // Refresh voucher list
        emit(VoucherLoaded(
          (state as VoucherLoaded?)?.vouchers ?? [],
          message: 'Voucher updated successfully',
        ));
      },
    );
  }

  Future<void> deleteVoucher(String voucherId) async {
    emit(VoucherLoading(vouchers: state.vouchers));
    final result = await repository.deleteVoucher(voucherId);
    result.fold(
      (error) => emit(VoucherError(
          state.vouchers, error.message ?? 'Error deleting voucher')),
      (_) async {
        await fetchVouchers(); // Refresh voucher list
        emit(VoucherLoaded(
          (state as VoucherLoaded?)?.vouchers ?? [],
          message: 'Voucher deleted successfully',
        ));
      },
    );
  }
}
