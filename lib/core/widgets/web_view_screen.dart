// lib/core/widgets/web_view_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Validate URL before loading
    String validUrl = widget.url;
    if (!validUrl.startsWith('http') && !validUrl.startsWith('https')) {
      validUrl = 'https://$validUrl';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: $error');
            setState(() {
              _error = 'Failed to load page';
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load URL
    try {
      _controller.loadRequest(Uri.parse(validUrl));
    } catch (e) {
      setState(() {
        _error = 'Invalid URL: ${widget.url}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _controller.reload();
            },
          ),
        ],
      ),
      body: _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: isDark ? Colors.white : Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}