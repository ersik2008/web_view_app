import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const WebApp());
}

class WebApp extends StatefulWidget {
  const WebApp({super.key});

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  late final WebViewController controller;
  double loading = 0;
  bool isError = false;
  //Добавить ваш url
  final String initialUrl = "";

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => loading = progress / 100);
          },
          onPageStarted: (_) {
            setState(() => isError = false);
          },
          onWebResourceError: (_) {
            setState(() => isError = true);
          },
          onPageFinished: (_) {
            setState(() => loading = 0);
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }

  Future<bool> onBack() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: onBack,
        child: Scaffold(
          body: Stack(
            children: [
              isError
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () =>
                            controller.loadRequest(Uri.parse(initialUrl)),
                        child: const Text("Перезагрузить"),
                      ),
                    )
                  : WebViewWidget(controller: controller),
              if (loading > 0)
                LinearProgressIndicator(
                  value: loading,
                  minHeight: 3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
