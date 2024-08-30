# graph_plus Example

Demonstrates how to use the graph_plus package

## Getting Started
```
flutter pub add graph_plus
```

## Create a graph
```dart
import 'package:graph_plus/graph.dart';

final graph = Graph(vertices: const[
    Vertex("A"),
    Vertex("B")
], edges: const [Edge.endpoints("a", "b")]);
```
If you need brevity in your code, consider using the abbreviated version:

```dart
import 'package: graph_plus/g.dart';

final g = G(vertices: const[
    V("A"),
    V("B")
], edges: const [E.endpoints("a", "b")]);
```