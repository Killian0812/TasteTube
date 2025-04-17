import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/voucher/voucher.dart';

class VoucherRepository {
  final Dio http;

  VoucherRepository({required this.http});

  Future<Either<ApiError, List<Voucher>>> fetchVouchers(String shopId) async {
    try {
      final response =
          await http.get(Api.voucherByShopApi.replaceFirst(":shopId", shopId));
      final List<dynamic> data = response.data;
      final vouchers = data.map((json) => Voucher.fromJson(json)).toList();
      return Right(vouchers);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Voucher>> createVoucher(Voucher voucher) async {
    try {
      final response = await http.post(
        Api.voucherApi,
        data: voucher.toJson(),
      );
      return Right(Voucher.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Voucher>> updateVoucher(
      String voucherId, Voucher voucher) async {
    try {
      final response = await http.put(
        Api.singleVoucherApi.replaceFirst(":id", voucherId),
        data: voucher.toJson(),
      );
      return Right(Voucher.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, void>> deleteVoucher(String voucherId) async {
    try {
      await http.delete(Api.singleVoucherApi.replaceFirst(":id", voucherId));
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
