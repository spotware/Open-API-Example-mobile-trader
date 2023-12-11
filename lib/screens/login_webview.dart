import 'dart:async';

import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebView extends StatefulWidget {
  const LoginWebView({super.key});

  static const String ROUTE_NAME = '/login/webview';

  @override
  State<LoginWebView> createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final AppState appState = GetIt.I<AppState>();

  final Map<String, String> params = <String, String>{
      'client_id': appState.clientID,
      'redirect_uri': 'https://login.confirm',
      'scope': 'trading',
      'product': 'mobile'
    };
    final Uri url = Uri.https(appState.loginURL, '/my/settings/openapi/grantingaccess/', params);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            Logger.error('onWebResourceError: ${error.errorCode}:${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final Uri url = Uri.parse(request.url);
            if (url.host == 'login.confirm') {
              final String? code = url.queryParameters['code'];
              Timer.run(() => Navigator.pop(context, code));
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel('Native', onMessageReceived: (JavaScriptMessage msg) {})
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
