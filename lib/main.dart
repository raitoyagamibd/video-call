

import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/index.dart';


const String appId = "<--Insert app ID here-->";

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agora',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const IndexPage(),
    );
  }
}

