import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathplanner/pathfinding/pivot_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';

void main() {
  test('equals/hashCode', () {
    PivotGrid grid1 = PivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        pivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    PivotGrid grid2 = PivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        pivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    PivotGrid grid3 = PivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        pivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), true)));

    expect(grid2, grid1);
    expect(grid3, isNot(grid1));

    expect(grid3.hashCode, isNot(grid1.hashCode));
  });

  test('toJson/fromJson interoperability', () {
    PivotGrid pivotGrid = PivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        pivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));

    Map<String, dynamic> json = pivotGrid.toJson();
    PivotGrid fromJson = PivotGrid.fromJson(json);

    expect(fromJson, pivotGrid);
  });

  test('bad data replaced', () {
    List<List<bool>> badGrid = List.generate((4.02 / 0.2).ceil(),
        (index) => List.filled((14.54 / 0.2).ceil(), true));
    PivotGrid pivotGrid = PivotGrid(
        fieldSize: const Size(16.54, 8.02), nodeSizeMeters: 0.2, pivotGrid: badGrid);
    Map<String, dynamic> json = pivotGrid.toJson();
    json.remove('field_size');
    PivotGrid fromJson = PivotGrid.fromJson(json);

    expect(fromJson.fieldSize.width,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().width, 0.01));
    expect(fromJson.fieldSize.height,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().height, 0.01));
    expect(
        const DeepCollectionEquality().equals(badGrid, fromJson.pivotGrid), false);
    for (var row in fromJson.pivotGrid) {
      for (var node in row) {
        expect(node, false);
      }
    }
  });
}
