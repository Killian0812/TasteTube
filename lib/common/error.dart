import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';

class ApiError {
  final int statusCode;
  final String? message;

  const ApiError(this.statusCode, [this.message]);

  ApiError.fromJson(this.statusCode, Map<String, dynamic> json)
      : message = json['message'] as String?;

  ApiError.fromDioException(DioException e)
      : statusCode = e.response?.statusCode ?? 500,
        message = e.response == null
            ? e.error.toString()
            : e.response?.data is Map
                ? e.response!.data['message']
                : e.response?.data as String?;
}

class ErrorPage extends StatelessWidget {
  final GoException? exception;

  const ErrorPage({super.key, this.exception});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),

                Text(
                  'Oops! Something Went Wrong',
                  style: CommonTextStyle.bold.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Error Message
                Text(
                  exception != null
                      ? 'Error: ${exception!.message}'
                      : 'The page you’re looking for can’t be found.',
                  style: CommonTextStyle.boldItalic.copyWith(
                    color: CommonColor.greyOutTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CommonColor.activeBgColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
