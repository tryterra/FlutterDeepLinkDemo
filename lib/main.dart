import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:uni_links/uni_links.dart';

// Uses https://github.com/avioli/uni_links/blob/master/uni_links/example/lib/main.dart

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;

  StreamSubscription? _sub;

  final _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void _handleIncomingLinks() {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      print('got uri: $uri');
      setState(() {
        _latestUri = uri;
        _err = null;
        print("attempting to close browser");
        FlutterWebBrowser.close()
            .then((value) => print('closed'))
            .catchError((e) => print(e));
        ;
      });
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
      setState(() {
        _latestUri = null;
        if (err is FormatException) {
          _err = err;
        } else {
          _err = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = _latestUri?.queryParametersAll.entries.toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Terra auth example with deep link'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        children: [
          if (_err != null)
            ListTile(
              title: const Text('Error', style: TextStyle(color: Colors.red)),
              subtitle: Text('$_err'),
            ),
          ListTile(
            title: const Text('Initial Uri'),
            subtitle: Text('$_initialUri'),
          ),
          if (true) ...[
            ListTile(
              title: const Text('Latest Uri'),
              subtitle: Text('$_latestUri'),
            ),
            ListTile(
              title: const Text('Latest Uri (path)'),
              subtitle: Text('${_latestUri?.path}'),
            ),
            ExpansionTile(
              initiallyExpanded: true,
              title: const Text('Latest Uri (query parameters)'),
              children: queryParams == null
                  ? const [ListTile(dense: true, title: Text('null'))]
                  : [
                      for (final item in queryParams)
                        ListTile(
                          title: Text(item.key),
                          trailing: Text(item.value.join(', ')),
                        )
                    ],
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the second screen using a named route.
                // Navigator.pushNamed(context, '/second');
                openBrowserTab();
              },
              child: const Text('Open Widget Session'),
            ),
          ],
          const Divider(),
        ],
      ),
    );
  }

  // use redirect URL with terraflutterdl://com.example.flutterDeepLink/{CUSTOM_PAGE}

  openBrowserTab() async {
    FlutterWebBrowser.openWebPage(
      url:
          "https://widget.tryterra.co/session/abfd85ad-86b0-43c7-9d2e-faa68eb23a31",
      customTabsOptions: const CustomTabsOptions(
        colorScheme: CustomTabsColorScheme.dark,
        shareState: CustomTabsShareState.on,
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: true,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
        preferredBarTintColor: Colors.blue,
        preferredControlTintColor: Colors.amber,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
      ),
    );
  }
}
