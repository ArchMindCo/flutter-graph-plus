import 'package:flutter/material.dart';
import 'package:graph_plus/diagraming/graph_view.dart';
import 'package:graph_plus/graphing/g.dart';

import 'diagraming/graph_view_grid_layout_delegate.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode mode = ThemeMode.light;
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  GraphViewOrientation orientation = GraphViewOrientation.vertical;

  @override
  Widget build(BuildContext context) {
    final recorder = GraphViewRecorder();
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      themeMode: mode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(actions: [
          OutlinedButton(onPressed: () {}, child: const Text("NoOp")),
          IconButton(
              onPressed: () {
                setState(() => orientation = switch (orientation) {
                      GraphViewOrientation.vertical =>
                        GraphViewOrientation.horizontal,
                      GraphViewOrientation.horizontal =>
                        GraphViewOrientation.vertical,
                    });
              },
              icon: Icon(switch (orientation) {
                GraphViewOrientation.vertical => Icons.horizontal_distribute,
                GraphViewOrientation.horizontal => Icons.vertical_distribute,
              })),
          IconButton(
              onPressed: () async {
                await recorder.capture(pixelRatio: 3);
                scaffoldKey.currentState!
                    .showSnackBar(const SnackBar(content: Text("copied!")));
              },
              icon: const Icon(Icons.content_copy)),
          TextButton(
              onPressed: () {
                setState(() {
                  mode = switch (mode) {
                    ThemeMode.light => ThemeMode.dark,
                    ThemeMode.dark => ThemeMode.system,
                    ThemeMode.system => ThemeMode.light
                  };
                });
              },
              child: Text("$mode")),
        ]),
        body: Center(
          // child: TextButton(
          //     onPressed: () {

          //     },
          //     child: const Text("Copy")),
          child: GraphView(
            Graph(vertices: const [
              V("a"),
              V("b", name: "BBBBB"),
              V("b1.1"),
              V("b1.2"),
              V("b1.3"),
              V("b1.2.1"),
              V("c"),
            ], edges: const [
              // E.endpoints("a", "b"),
              E.endpoints("b", "b1.1"),
              E.endpoints("b", "b1.2"),
              E.endpoints("b", "b1.3"),
              E.endpoints("b1.1", "b1.2"),
              E.endpoints("b1.2", "b1.2.1"),
              E.endpoints("b", "c"),
            ]),
            //useAppTheme: false,
            //theme: const GraphViewThemeData(vertexBorderColor: Colors.blue),
            //darkTheme: const GraphViewThemeData(vertexBorderColor: Colors.red),
            grouping: GraphViewGrouping(
              assignGroup: (V<String> vertex) {
                //return {"a"};
                final set = <String>{};
                if (vertex.id.startsWith("b")) {
                  set.add("a");
                }
                if (vertex.id.startsWith("b1.2")) {
                  set.add("b");
                }
                if (vertex.id == "c") {
                  set.add("c");
                }

                return set;
              },
            ),
            orientation: orientation,

            layoutDelegate: GraphViewGridLayoutDelegate(),
            buildDelegate: GraphViewBuildDelegate(
              groupBorderRadius: 20,
              buildVertex: (context, theme, vertex) => Container(
                decoration: BoxDecoration(
                    border: Border.all(color: theme.vertexBorderColor)
                    // color: Colors.green,
                    ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(onPressed: () {}, child: Text(vertex.name)),
                ),
              ),
              buildGroup: (context, theme, group) =>
                  TextButton(onPressed: () {}, child: const Text("Some Group")),
            ),
            recorder: recorder,
          ),
        ),
      ),
    );
  }
}
