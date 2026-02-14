import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const XWrapperApp());
}

class XWrapperApp extends StatelessWidget {
  const XWrapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X Wrapper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const XWebViewPage(),
      },
    );
  }
}

class XWebViewPage extends StatefulWidget {
  const XWebViewPage({super.key});

  @override
  State<XWebViewPage> createState() => _XWebViewPageState();
}

class _XWebViewPageState extends State<XWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000)) // X brand color (black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // You can update a loading bar here if desired
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web Resource Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Here you can block specific URLs if needed
            // For now, we allow everything to navigate within the WebView
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://x.com'));
  }

  @override
  Widget build(BuildContext context) {
    // PopScope handles the Android back button to navigate browser history
    // instead of immediately closing the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          await _controller.goBack();
        } else {
          // If no history, allow the app to close
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // We use SafeArea to avoid notches and system bars
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              
              // Optional: Show a loading indicator when navigating
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
