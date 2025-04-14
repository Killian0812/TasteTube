import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ShopAnalyticState {}

class ShopAnalyticInitial extends ShopAnalyticState {}

class ShopAnalyticLoading extends ShopAnalyticState {}

class ShopAnalyticLoaded extends ShopAnalyticState {
  final AnalyticsData analytics;
  ShopAnalyticLoaded(this.analytics);
}

class ShopAnalyticError extends ShopAnalyticState {
  final String message;
  ShopAnalyticError(this.message);
}

class ShopAnalyticCubit extends Cubit<ShopAnalyticState> {
  ShopAnalyticCubit() : super(ShopAnalyticInitial());

  Future<void> fetchAnalytics(String userId) async {
    try {
      emit(ShopAnalyticLoading());
      await Future.delayed(const Duration(seconds: 1));

      final analytics = AnalyticsData(
        totalRevenue: 12500.50,
        orderCount: 150,
        averageOrderValue: 83.34,
        dailySales: {
          'Monday': 1500.0,
          'Tuesday': 1800.0,
          'Wednesday': 1200.0,
          'Thursday': 2000.0,
          'Friday': 2200.0,
          'Saturday': 1900.0,
          'Sunday': 2300.0,
        },
        videoViews: 4500,
        positiveReviews: 80,
        neutralReviews: 50,
        negativeReviews: 20,
        topProducts: [
          ProductSales(
              name: 'Spicy Noodles', sales: 50, revenue: 750.0, rating: 4.5),
          ProductSales(
              name: 'Matcha Latte', sales: 40, revenue: 600.0, rating: 4.2),
          ProductSales(
              name: 'Chocolate Cake', sales: 30, revenue: 450.0, rating: 4.8),
          ProductSales(
              name: 'Sushi Platter', sales: 20, revenue: 400.0, rating: 4.6),
        ],
        topCategories: [
          CategorySales(
              name: 'Main Courses', sales: 70, revenue: 9000.0, growth: 12.5),
          CategorySales(
              name: 'Beverages', sales: 50, revenue: 2000.0, growth: 8.3),
          CategorySales(
              name: 'Desserts', sales: 30, revenue: 1500.0, growth: 15.0),
        ],
        conversionRate: 3.5,
        returningCustomers: 65,
        newCustomers: 85,
        paymentMethods: [
          PaymentMethod(name: 'COD', count: 90, percentage: 60.0),
          PaymentMethod(name: 'VNPAY', count: 45, percentage: 30.0),
          PaymentMethod(name: 'ZALOPAY', count: 15, percentage: 10.0),
        ],
      );

      emit(ShopAnalyticLoaded(analytics));
    } catch (e) {
      emit(ShopAnalyticError(e.toString()));
    }
  }
}

class AnalyticsData {
  final double totalRevenue;
  final int orderCount;
  final double averageOrderValue;
  final Map<String, double> dailySales;
  final int videoViews;
  final int positiveReviews;
  final int neutralReviews;
  final int negativeReviews;
  final List<ProductSales> topProducts;
  final List<CategorySales> topCategories;
  final double conversionRate;
  final int returningCustomers;
  final int newCustomers;
  final List<PaymentMethod> paymentMethods;

  AnalyticsData({
    required this.totalRevenue,
    required this.orderCount,
    required this.averageOrderValue,
    required this.dailySales,
    required this.videoViews,
    required this.positiveReviews,
    required this.neutralReviews,
    required this.negativeReviews,
    required this.topProducts,
    required this.topCategories,
    required this.conversionRate,
    required this.returningCustomers,
    required this.newCustomers,
    required this.paymentMethods,
  });
}

class ProductSales {
  final String name;
  final int sales;
  final double revenue;
  final double rating;

  ProductSales({
    required this.name,
    required this.sales,
    required this.revenue,
    required this.rating,
  });
}

class CategorySales {
  final String name;
  final int sales;
  final double revenue;
  final double growth; // percentage growth

  CategorySales({
    required this.name,
    required this.sales,
    required this.revenue,
    required this.growth,
  });
}

class CustomerDemo {
  final String group;
  final int count;
  final double percentage;
  final double avgSpend;

  CustomerDemo({
    required this.group,
    required this.count,
    required this.percentage,
    required this.avgSpend,
  });
}

class PaymentMethod {
  final String name;
  final int count;
  final double percentage;

  PaymentMethod({
    required this.name,
    required this.count,
    required this.percentage,
  });
}
