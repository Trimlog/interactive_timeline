import 'package:example/state_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:interactive_timeline/interactive_timeline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InteractiveTimelineCubit timelineCubit = InteractiveTimelineCubit(
    minCursor: DateTime.now().subtract(Duration(hours: 1)),
    maxCursor: DateTime.now().add(Duration(hours: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StateVisualizer(cubit: timelineCubit),
            InteractiveTimeline(
              width: MediaQuery.of(context).size.width,
              height: 100,
              cubit: timelineCubit,
              color: Color.fromARGB(255, 201, 201, 201),
              padding: EdgeInsets.all(10),
            )
          ],
        ),
      ),
    );
  }
}
