import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/core/injection.dart';

void _logDefaultAnalyticsEvent(
  String url,
  String method,
  Map<String, dynamic>? data,
  Map<String, dynamic> query,
) {
  final analytics = FirebaseAnalytics.instance;

  if (url.contains(Api.addCartApi) && method == 'POST') {
    analytics.logAddToCart(
      items: [
        AnalyticsEventItem(
          itemId: data?['productId'],
          quantity: data?['quantity'],
        )
      ],
    );
  } else if (url.contains(Api.cartApi) && method == 'GET') {
    analytics.logViewCart();
  } else if (url.contains(Api.videoApi) && method == 'GET') {
    analytics.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: url.split('/').last,
          itemName: 'video',
        )
      ],
    );
  } else if (url.contains(Api.productApi) && method == 'GET') {
    AnalyticsEventItem(
      itemId: url.split('/').last,
      itemName: 'product',
    );
  } else if (url.contains(Api.addCard)) {
    analytics.logAddPaymentInfo(
      paymentType: data?['type'],
    );
  } else if (url.contains(Api.getVnpayUrl)) {
    analytics.logAddPaymentInfo(
      paymentType: "DOMESTIC CARD",
      currency: data?['currency'],
      value: data?['amount'],
    );
  } else if (url.contains(Api.addressApi) && method == 'POST') {
    analytics.logAddShippingInfo();
  } else if (url.contains('/order-delivery/') && method == 'POST') {
    analytics.logAddShippingInfo(
      shippingTier: query['deliveryType'],
    );
  } else if (url.contains(Api.orderApi) && method == 'POST') {
    analytics.logBeginCheckout(parameters: data?.cast<String, Object>());
  }
}

Dio getHttpClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${Api.baseUrl}/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': true, // Bypass ngrok warning
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add a timestamp to track request start time
        options.extra['startTime'] = DateTime.now();

        // Log default Firebase Analytics events
        try {
          _logDefaultAnalyticsEvent(
            options.uri.toString(),
            options.method,
            (options.data is FormData) ? {} : options.data,
            options.queryParameters,
          );
        } catch (e) {
          getIt<Logger>().e("Unable to send firebase analytics", error: e);
        }

        // Log a custom Firebase Analytics event
        FirebaseAnalytics.instance.logEvent(
          name: 'http_request',
          parameters: {
            'method': options.method,
            'url': options.uri.toString(),
          },
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Calculate response time
        final startTime =
            response.requestOptions.extra['startTime'] as DateTime?;
        if (startTime != null) {
          final responseTime =
              DateTime.now().difference(startTime).inMilliseconds;
          FirebaseAnalytics.instance.logEvent(
            name: 'http_response',
            parameters: {
              'url': response.requestOptions.uri.toString(),
              'time': responseTime,
            },
          );
        }
        handler.next(response);
      },
      onError: (error, handler) {
        // Calculate response time for errors
        final startTime = error.requestOptions.extra['startTime'] as DateTime?;
        if (startTime != null) {
          final responseTime =
              DateTime.now().difference(startTime).inMilliseconds;
          FirebaseAnalytics.instance.logEvent(
            name: 'http_error',
            parameters: {
              'url': error.requestOptions.uri.toString(),
              'time': responseTime,
            },
          );
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}
