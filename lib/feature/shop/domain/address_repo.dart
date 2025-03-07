import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/order/address.dart';

class AddressRepository {
  final Dio http;

  AddressRepository({required this.http});

  Future<Either<ApiError, List<Address>>> getAddresses() async {
    try {
      final response = await http.get(Api.addressApi);
      final List<dynamic> data = response.data;
      final addresses = data.map((json) => Address.fromJson(json)).toList();
      return Right(addresses);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Address>> upsertAddress(
    String? id,
    String name,
    String phone,
    String value,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.post(Api.addressApi, data: {
        'name': name,
        'phone': phone,
        'value': value,
        'latitude': latitude,
        'longitude': longitude,
      }, queryParameters: {
        "addressId": id,
      });
      final address = Address.fromJson(response.data);
      return Right(address);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, void>> deleteAddress(String id) async {
    try {
      await http.delete(Api.singleAddressApi.replaceFirst(':addressId', id));
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
