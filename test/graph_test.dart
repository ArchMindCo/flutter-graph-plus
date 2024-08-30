// ignore_for_file: prefer_const_constructors

// Omit using const constructors in tests that require equality
// Otherwise, the const will hide equality operations and invalidate the test

import 'package:flutter_test/flutter_test.dart';
import 'package:graph_plus/graphing/g.dart';

void main() {
  group("Vertex", () {
    test("equality of two vertices", () {
      final v1 = V("a");
      final v2 = V("a");

      expect(v1 == v2, true);
    });

    test("equality of two unequal vertices", () {
      // Don't use const constructors otherwise, its not a valid test
      final v1 = V("a");
      final v2 = V("b");

      expect(v1 == v2, false);
    });

    test("equality of a vertex and temporal vertex", () {
      // Don't use const constructors otherwise, its not a valid test
      final v1 = V("a");
      final v2 = VS(V("a"));

      expect(v1 == v2, true);
    });
  });

  group("Edge", () {
    // ignore: prefer_const_declarations
    final id1 = ("a", "b");
    final edge1 = Edge(id1);

    test("Equality", () {
      final edge2 = Edge.endpoints("a", "b");
      // ignore: unrelated_type_equality_checks
      expect(edge1 == id1, true);
      expect(edge1 == edge2, true);
    });

    test("Not equal", () {
      final edge2 = Edge.endpoints("a", "c");

      expect(edge1 == edge2, false);
    });
  });

  group("Graph", () {
    group("Creational", () {
      test("Creating an empty graph", () {
        final graph = G.empty();
        expect(graph.order, 0);
        expect(graph.size, 0);
      });
    });

    group("Queries", () {
      final graph = G(
          vertices: const [V("a"), V("b")],
          edges: const [E.endpoints("a", "b")]);
      test("parentsOf", () {
        final parentsOfB = graph.parentsOfById("b");
        expect(parentsOfB.length, 1);
        expect(parentsOfB.values.first == V("a"), true);
      });

      test("childrenOf", () {
        final childrenOfA = graph.childrenOfById("a");
        expect(childrenOfA.length, 1);
        expect(childrenOfA.values.first == V("b"), true);
      });
    });

    group("Update", () {
      test("Adding a vertex by method", () {
        final graph = G.empty();
        final GS updated = graph.addVertex(const V("a"));
        expect(updated.order, 1);
        expect(updated.getOrderByState(SS.added), 1);
      });

      test("Adding a vertex by operator", () {
        final graph = G.empty();
        final GS updated = graph + const V("a");
        expect(updated.order, 1);
        expect(updated.getOrderByState(SS.added), 1);
      });

      test("Adding a graph by method", () {
        final graph1 = G.empty();
        final graph2 = G(vertices: [const V("a")]);
        final GS updated = graph1.addGraph(graph2);
        expect(updated.order, 1);
        expect(updated.getOrderByState(SS.added), 1);
      });

      test("Adding a graph by operator", () {
        final graph1 = G.empty();
        final graph2 = G(vertices: [const V("a")]);
        final GS updated = graph1 + graph2;

        expect(updated.getOrderByState(SS.added), 1);
        expect(updated.getOrderByState(SS.modified), 0);
        expect(updated.getOrderByState(SS.removed), 0);
        expect(updated.getOrderByState(SS.unmodified), 0);
      });

      test("Adding a non-empty graphs", () {
        final graph1 = G(vertices: [const V("a"), const V("b")]);
        final graph2 = G(vertices: [const V("b"), const V("c")]);
        final GS updated = graph1 + graph2;

        expect(updated.getOrderByState(SS.added), 1);
        expect(updated.getOrderByState(SS.modified), 0);
        expect(updated.getOrderByState(SS.removed), 0);
        expect(updated.getOrderByState(SS.unmodified), 2);
      });

      test("Diff precision", () {
        final graph1 = G(vertices: const [V("a"), V("b"), V("c")]);
        final graph2 = G(vertices: const [V("a"), V("b"), V("d")]);
        final GS diff = graph1 - graph2;

        expect(diff.getOrderByState(SS.added), 1);
        expect(diff.getOrderByState(SS.modified), 0);
        expect(diff.getOrderByState(SS.removed), 1);
        expect(diff.getOrderByState(SS.unmodified), 2);

        expect(diff.verticesByState(SS.added).values.first, const V("d"));
        expect(diff.verticesByState(SS.removed).values.first, const V("c"));
        expect(diff.verticesByState(SS.unmodified).values.elementAt(0),
            const V("a"));
        expect(diff.verticesByState(SS.unmodified).values.elementAt(1),
            const V("b"));
      });
    });

    group("Metadata", () {
      test("basic", () {
        final graph = G(vertices: const [V("a"), V("b")]);
        expect(graph.metadata.sources.length, 2);
        expect(graph.metadata.sinks.length, 2);
      });

      test("basic with edge", () {
        final graph = G(
            vertices: const [V("a"), V("b")],
            edges: const [E.endpoints("a", "b")]);
        expect(graph.metadata.sources.length, 1);
        expect(graph.metadata.sinks.length, 1);

        expect(graph.metadata.sources.values.first == V("a"), true);
        expect(graph.metadata.sinks.values.first == V("b"), true);
      });
    });
  });

  group("Timeline", () {
    test("Empty", () {
      final graph = StatefulGraph();
      expect(graph.order, 0);
      expect(graph.size, 0);
    });

    test("Add a vertex", () {
      final graph = SG();
      graph + const V("a");

      expect(graph.order, 1);

      graph.toFirst();
      expect(graph.order, 0);
    });
  });

  group("Metadata", () {});
}
