import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/feature/payment/view/payment_cubit.dart';

class OnlinePaymentPage extends StatelessWidget {
  final String url;
  final PaymentCubit cubit;

  const OnlinePaymentPage({
    super.key,
    required this.url,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      bloc: cubit,
      listener: (context, state) {
        if (state is PaymentSuccess) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('TasteTube Online Payment'),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url)),
          onWebViewCreated: (InAppWebViewController webViewController) {
            // Not working
            webViewController.addJavaScriptHandler(
              handlerName: 'popPage',
              callback: (args) {
                Navigator.pop(context);
              },
            );
            webViewController.evaluateJavascript(source: '''
                document.getElementById('continue').addEventListener('click', function() {
                  window.flutter_inappwebview.callHandler('popPage');
                });
              ''');
          },
        ),
      ),
    );
  }
}
