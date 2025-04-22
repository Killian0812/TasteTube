class ShopAnalytics {
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
  final String currency;

  ShopAnalytics({
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
    required this.currency,
  });

  factory ShopAnalytics.fromJson(Map<String, dynamic> json) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final dailySales = Map<String, double>.from(json['dailySales']);
    for (var day in weekdays) {
      dailySales.putIfAbsent(day, () => 0.0);
    }

    return ShopAnalytics(
      totalRevenue: json['totalRevenue'],
      orderCount: json['orderCount'],
      averageOrderValue: json['averageOrderValue'],
      dailySales: dailySales,
      videoViews: json['videoViews'],
      positiveReviews: json['positiveReviews'],
      neutralReviews: json['neutralReviews'],
      negativeReviews: json['negativeReviews'],
      topProducts: (json['topProducts'] as List)
          .map((item) => ProductSales.fromJson(item))
          .toList(),
      topCategories: (json['topCategories'] as List)
          .map((item) => CategorySales.fromJson(item))
          .toList(),
      conversionRate: json['conversionRate'],
      returningCustomers: json['returningCustomers'],
      newCustomers: json['newCustomers'],
      paymentMethods: (json['paymentMethods'] as List)
          .map((item) => PaymentMethod.fromJson(item))
          .toList(),
      currency: json['currency'] ?? 'VND',
    );
  }
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

  factory ProductSales.fromJson(Map<String, dynamic> json) {
    return ProductSales(
      name: json['name'],
      sales: json['sales'],
      revenue: json['revenue'],
      rating: json['rating'],
    );
  }
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

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      name: json['name'],
      sales: json['sales'],
      revenue: json['revenue'],
      growth: json['growth'],
    );
  }
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

  factory CustomerDemo.fromJson(Map<String, dynamic> json) {
    return CustomerDemo(
      group: json['group'],
      count: json['count'],
      percentage: json['percentage'],
      avgSpend: json['avgSpend'],
    );
  }
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

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      name: json['name'],
      count: json['count'],
      percentage: json['percentage'],
    );
  }
}
