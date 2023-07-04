// ignore_for_file: dead_code, non_constant_identifier_names, duplicate_ignore

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:flutter_shortcuts/flutter_shortcuts.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String action = 'No Action';
  Widget shortpage = const MyHomePage();
  final FlutterShortcuts flutterShortcuts = FlutterShortcuts();
  @override
  void initState() {
    super.initState();
    flutterShortcuts.initialize(debug: true);
    flutterShortcuts.setShortcutItems(
      shortcutItems: <ShortcutItem>[
        const ShortcutItem(
          id: "1",
          action: '0',
          shortLabel: 'Wifi',
          icon: "ic_wifi",
          shortcutIconAsset: ShortcutIconAsset.androidAsset,
        ),
        const ShortcutItem(
          id: "2",
          action: '1',
          shortLabel: 'SIS',
          icon: "ic_sis",
          shortcutIconAsset: ShortcutIconAsset.androidAsset,
        ),
      ],
    );
    flutterShortcuts.listenAction((String incomingAction) {
      setState(() {
        if (incomingAction == "1") {
          shortpage = const MyHomePage2();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Utu Login',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: shortpage,
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

Future<List<String>> extractData() async {
  // Getting the response from the targeted url
  final response = await http.Client().get(
      Uri.parse('https://github.com/Kalpu-24/UTULogin/blob/main/README.md'));

  // Status Code 200 means response has been received successfully
  if (response.statusCode == 200) {
    // Getting the html document from the response
    var document = parser.parse(response.body);
    try {
      // Scraping the first article title
      var responseString1 = document
          .querySelectorAll("h2")[1]
          .text
          .trim()
          .split(' ')[1]
          .split('+')[0];
      var responseString2 = document
          .querySelectorAll("h2")[1]
          .text
          .trim()
          .split(' ')[1]
          .split('+')[1];

      if (kDebugMode) {
        print(responseString1);
      }
      return [responseString1.toString(), responseString2.toString()];
    } catch (e) {
      return ['', 'ERROR!'];
    }
  } else {
    return ['', 'ERROR: ${response.statusCode}.'];
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // bool upavai = false;
    var appState = context.watch<MyAppState>();
    // Version currentVersion;

    // appState.getVer().then((gvalue) async {
    //   currentVersion = Version.parse(appState.data.elementAt(0));
    //   await extractData().then((value) async {
    //     Version latestVersion = Version.parse(value[0]);
    //     if (latestVersion > currentVersion) {
    //       // ignore: avoid_print
    //       upavai = true;
    //     } else if (latestVersion == currentVersion) {
    //     } else {}
    //   });
    // });

    Widget Page;
    appState.check();
    if (appState.saved) {
      Page = LoginPage();
    } else {
      Page = const NoDataPage();
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('UTU Login'),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage2()),
                    );
                  },
                  child: const Text("SIS")),
            )
          ],
        ),
        body:
            //upavai
            //     ? AlertDialog(
            //         content: Text("yoooo"),
            //       )
            //     :
            Page,
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

class MyHomePage2 extends StatelessWidget {
  const MyHomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    // bool upavai = false;
    var appState = context.watch<MyAppState>();
    // Version currentVersion;

    // appState.getVer().then((gvalue) async {
    //   currentVersion = Version.parse(appState.data.elementAt(0));
    //   await extractData().then((value) async {
    //     Version latestVersion = Version.parse(value[0]);
    //     if (latestVersion > currentVersion) {
    //       // ignore: avoid_print
    //       upavai = true;
    //     } else if (latestVersion == currentVersion) {
    //     } else {}
    //   });
    // });

    Widget Page;
    appState.check();
    if (appState.saved) {
      Page = Sis();
    } else {
      Page = const NoDataPage();
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('UTU Login'),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()),
                    );
                  },
                  child: const Text("Wifi")),
            )
          ],
        ),
        body:
            //upavai
            //     ? AlertDialog(
            //         content: Text("yoooo"),
            //       )
            //     :
            Page,
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

// ignore: must_be_immutable
class Sis extends StatelessWidget {
  // ignore: non_constant_identifier_names
  String SiUs = " ";
  // ignore: non_constant_identifier_names
  String SiPpass = " ";
  Sis({
    super.key,
  });

  void getPre() async {
    final prefs = await SharedPreferences.getInstance();
    SiUs = prefs.getString("username").toString();
    SiPpass = prefs.getString("Sipassword").toString();
  }

  @override
  Widget build(BuildContext context) {
    getPre();
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.https('app.utu.ac.in', 'UTUSIS/SIS/Login.aspx')),
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
    getElementByXPath('/html/body/form/div[3]/fieldset/p[1]/input').value = "$SiUs";
    getElementByXPath('/html/body/form/div[3]/fieldset/p[2]/input').value = "$SiPpass";
    getElementByXPath('/html/body/form/div[3]/fieldset/p[3]/input').click();
    ''');
        // 51
      },
    );
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
  TextEditingController sipass = TextEditingController();
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
                return 'Please enter your enrollment No.';
              }
              return null;
            },
          ),
          TextFormField(
            controller: pass,
            decoration: const InputDecoration(
              hintText: 'Enter your  wifi password',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your wifi password';
              }
              return null;
            },
          ),
          TextFormField(
            controller: sipass,
            decoration: const InputDecoration(
              hintText: 'Enter your SIS password',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your SIS password';
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
                  _save(context, username.text, pass.text, sipass.text);
                }
              },
              child: const Text('Save'),
            ),
          ),
          const Center(child: Text("Made By Kalp"))
        ],
      ),
    );
  }

  Future<void> _save(
      BuildContext context, String u, String p, String sp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", u);
    await prefs.setString("password", p);
    await prefs.setString("Sipassword", sp);
    // ignore: use_build_context_synchronously
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
