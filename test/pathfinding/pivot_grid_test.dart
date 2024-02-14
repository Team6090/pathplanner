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
        grid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    PivotGrid grid2 = PivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        grid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    PivotGrid grid3 = PivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        grid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), true)));

    expect(grid2, grid1);
    expect(grid3, isNot(grid1));

    expect(grid3.hashCode, isNot(grid1.hashCode));
  });

  test('toJson/fromJson interoperability', () {
    PivotGrid grid = PivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        grid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));

    Map<String, dynamic> json = grid.toJson();
    PivotGrid fromJson = PivotGrid.fromJson(json);

    expect(fromJson, grid);
  });

  test('bad data replaced', () {
    List<List<bool>> badGrid = List.generate((4.02 / 0.2).ceil(),
        (index) => List.filled((14.54 / 0.2).ceil(), true));
    PivotGrid grid = PivotGrid(
        fieldSize: const Size(16.54, 8.02), nodeSizeMeters: 0.2, grid: badGrid);
    Map<String, dynamic> json = grid.toJson();
    json.remove('field_size');
    PivotGrid fromJson = PivotGrid.fromJson(json);

    expect(fromJson.fieldSize.width,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().width, 0.01));
    expect(fromJson.fieldSize.height,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().height, 0.01));
    expect(
        const DeepCollectionEquality().equals(badGrid, fromJson.grid), false);
    for (var row in fromJson.grid) {
      for (var node in row) {
        expect(node, false);
      }
    }
  });
}
