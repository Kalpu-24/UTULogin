// ignore_for_file: dead_code, non_constant_identifier_names, duplicate_ignore

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var saved = false;
  Set data = {};
  Future<void> getVer() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    data.add(version);
    data.add(buildNumber);
    notifyListeners();
  }

  Future<void> check() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("username") && prefs.containsKey("password")) {
      saved = true;
    } else {
      saved = false;
    }
    notifyListeners();
  }

  void saveded() {
    saved = true;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool upavai = false;
    var appState = context.watch<MyAppState>();
    appState.getVer().then((value) {
      Version currentVersion = Version.parse(appState.data.elementAt(0));
      Version latestVersion = Version.parse("0.0.2");
      if (latestVersion > currentVersion) {
        // ignore: avoid_print
        upavai = true;
      } else if (latestVersion == currentVersion) {
        if (appState.data.elementAt(0) == "1") {
          // ignore: avoid_print
          print("This is a beta version");
        } else {
          // ignore: avoid_print
          print("This is a stable version");
        }
      }
    });

    Widget Page;
    appState.check();
    if (appState.saved) {
      Page = LoginPage();
    } else {
      Page = const NoDataPage();
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('UTU Login WebView'),
        ),
        body: upavai
            ? AlertDialog(
                content: Text("yoooo"),
              )
            : Page,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  // Retrieve the text the that user has entered by using the
                  // TextEditingController.
                  content: MyForm(),
                );
              },
            );
          },
          tooltip: 'Configure',
          child: const Icon(Icons.settings),
        ));
  }
}

class NoDataPage extends StatelessWidget {
  const NoDataPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
          "No Data Found\nPlease Configure your enrollment no. and password from the settings button"),
    );
  }
}

// ignore: must_be_immutable, duplicate_ignore
class LoginPage extends StatelessWidget {
  // ignore: non_constant_identifier_names
  String Us = " ";
  // ignore: non_constant_identifier_names
  String Ppass = " ";
  LoginPage({
    super.key,
  });

  void getPre() async {
    final prefs = await SharedPreferences.getInstance();
    Us = prefs.getString("username").toString();
    Ppass = prefs.getString("password").toString();
  }

  @override
  Widget build(BuildContext context) {
    getPre();
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.https('auth.utu.ac.in:4100')),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
            source: "var foo = 49;",
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START),
        UserScript(
            source: "var bar = 2;",
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END),
      ]),
      onLoadStop: (controller, url) async {
        await controller.evaluateJavascript(source: '''
     function getElementByXPath(xpath) {
      return new XPathEvaluator()
        .createExpression(xpath)
        .evaluate(document, XPathResult.FIRST_ORDERED_NODE_TYPE)
        .singleNodeValue
    }
    getElementByXPath('//*[@id="hsFormId"]/table/tbody/tr[2]/td/table/tbody/tr[3]/td[2]/table/tbody/tr[1]/td[2]/table/tbody/tr[2]/td[2]/input').value = "$Us";
    getElementByXPath('//*[@id="hsFormId"]/table/tbody/tr[2]/td/table/tbody/tr[3]/td[2]/table/tbody/tr[1]/td[2]/table/tbody/tr[4]/td[2]/input').value = "$Ppass";
    getElementByXPath('//*[@id="hsFormId"]/table/tbody/tr[2]/td/table/tbody/tr[3]/td[2]/table/tbody/tr[1]/td[2]/table/tbody/tr[8]/td[2]/div/input[1]').click();
    ''');
        // 51
      },
    );
  }
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyForm();
}

class _MyForm extends State<MyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController pass = TextEditingController();
  String Us = "";
  String Ppass = "";
  void getPre() async {
    final prefs = await SharedPreferences.getInstance();
    Us = prefs.getString("username").toString();
    Ppass = prefs.getString("password").toString();
  }

  @override
  Widget build(BuildContext context) {
    getPre();
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: username,
            decoration: const InputDecoration(
              hintText: 'Enter your enrollment No.',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: pass,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  _save(context, username.text, pass.text);
                }
              },
              child: const Text('Submit'),
            ),
          ),
          const Center(child: Text("Made By Kalp"))
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, String u, String p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", u);
    await prefs.setString("password", p);
    // ignore: use_build_context_synchronously
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
