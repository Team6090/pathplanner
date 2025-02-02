import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathplanner/pathfinding/nav_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';

void main() {
  test('equals/hashCode', () {
    NavGrid grid1 = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    NavGrid grid2 = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    NavGrid grid3 = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), true)));

    expect(grid2, grid1);
    expect(grid3, isNot(grid1));

    expect(grid3.hashCode, isNot(grid1.hashCode));
  });

  test('toJson/fromJson interoperability', () {
    NavGrid navGrid = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));

    Map<String, dynamic> json = navGrid.toJson();
    NavGrid fromJson = NavGrid.fromJson(json);

    expect(fromJson, navGrid);
  });

  test('bad data replaced', () {
    List<List<bool>> badGrid = List.generate((4.02 / 0.2).ceil(),
        (index) => List.filled((14.54 / 0.2).ceil(), true));
    NavGrid navGrid = NavGrid(
        fieldSize: const Size(16.54, 8.02), nodeSizeMeters: 0.2, navGrid: badGrid);
    Map<String, dynamic> json = navGrid.toJson();
    json.remove('field_size');
    NavGrid fromJson = NavGrid.fromJson(json);

    expect(fromJson.fieldSize.width,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().width, 0.01));
    expect(fromJson.fieldSize.height,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().height, 0.01));
    expect(
        const DeepCollectionEquality().equals(badGrid, fromJson.navGrid), false);
    for (var row in fromJson.navGrid) {
      for (var node in row) {
        expect(node, false);
      }
    }
  });
}
