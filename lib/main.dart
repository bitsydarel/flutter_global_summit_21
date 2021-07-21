import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

///
const ValueKey<String> openUsersPage = ValueKey<String>('open_users');

/// My Application
class MyApp extends StatelessWidget {
  /// My application user count.
  final int userCount;

  ///
  const MyApp({this.userCount = 100, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) {
          return const MyHomePage(title: 'Flutter Demo Home Page');
        },
        '/users': (BuildContext context) {
          return MyUsersPage(userCount: userCount);
        }
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('userCount', userCount));
  }
}

/// My home page.
class MyHomePage extends StatefulWidget {
  ///
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  /// Title of the home page
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: openUsersPage,
              onPressed: () => Navigator.of(context).pushNamed('/users'),
              child: const Text('Show Users'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// My user list
class MyUsersPage extends StatelessWidget {
  static final Random _randomName = Random(1000000);

  ///
  final int userCount;

  ///
  const MyUsersPage({required this.userCount, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListView.builder(
        itemCount: userCount,
        itemBuilder: (BuildContext itemContext, int index) {
          return ListTile(
            key: ValueKey<int>(index),
            leading: CircleAvatar(child: Text('#$index')),
            title: Text('User$index id ${_randomName.nextDouble()} '),
            onTap: () {
              ScaffoldMessenger.of(itemContext).showSnackBar(
                SnackBar(content: Text('You clicked on user $index')),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('userCount', userCount));
  }
}
