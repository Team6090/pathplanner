import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathplanner/pathfinding/red_auto_pivot_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';

void main() {
  test('equals/hashCode', () {
    RedAutoPivotGrid grid1 = RedAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        redAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    RedAutoPivotGrid grid2 = RedAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        redAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    RedAutoPivotGrid grid3 = RedAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        redAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), true)));

    expect(grid2, grid1);
    expect(grid3, isNot(grid1));

    expect(grid3.hashCode, isNot(grid1.hashCode));
  });

  test('toJson/fromJson interoperability', () {
    RedAutoPivotGrid redAutoPivotGrid = RedAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        redAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));

    Map<String, dynamic> json = redAutoPivotGrid.toJson();
    RedAutoPivotGrid fromJson = RedAutoPivotGrid.fromJson(json);

    expect(fromJson, redAutoPivotGrid);
  });

  test('bad data replaced', () {
    List<List<bool>> badGrid = List.generate((4.02 / 0.2).ceil(),
        (index) => List.filled((14.54 / 0.2).ceil(), true));
    RedAutoPivotGrid pivotGrid = RedAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02), nodeSizeMeters: 0.2, redAutoPivotGrid: badGrid);
    Map<String, dynamic> json = pivotGrid.toJson();
    json.remove('field_size');
    RedAutoPivotGrid fromJson = RedAutoPivotGrid.fromJson(json);

    expect(fromJson.fieldSize.width,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().width, 0.01));
    expect(fromJson.fieldSize.height,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().height, 0.01));
    expect(
        const DeepCollectionEquality().equals(badGrid, fromJson.redAutoPivotGrid), false);
    for (var row in fromJson.redAutoPivotGrid) {
      for (var node in row) {
        expect(node, false);
      }
    }
  });
}
