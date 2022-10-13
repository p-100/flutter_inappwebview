import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void loadFile() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('loadFile', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final StreamController<String> pageLoads =
        StreamController<String>.broadcast();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoads.add(url!.toString());
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoads.stream.first;

    await controller.loadFile(
        assetFilePath: "test_assets/in_app_webview_initial_file_test.html");
    await pageLoads.stream.first;

    final Uri? url = await controller.getUrl();
    expect(url, isNotNull);
    expect(url!.scheme, kIsWeb ? 'http' : 'file');
    expect(url.path,
        endsWith("test_assets/in_app_webview_initial_file_test.html"));

    pageLoads.close();
  }, skip: shouldSkip);
}