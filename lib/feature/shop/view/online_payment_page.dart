import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class OnlinePaymentPage extends StatelessWidget {
  final String url;
  const OnlinePaymentPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
