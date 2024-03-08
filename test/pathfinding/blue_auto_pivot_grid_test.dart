import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathplanner/pathfinding/blue_auto_pivot_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';

void main() {
  test('equals/hashCode', () {
    BlueAutoPivotGrid grid1 = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    BlueAutoPivotGrid grid2 = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    BlueAutoPivotGrid grid3 = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), true)));

    expect(grid2, grid1);
    expect(grid3, isNot(grid1));

    expect(grid3.hashCode, isNot(grid1.hashCode));
  });

  test('toJson/fromJson interoperability', () {
    BlueAutoPivotGrid blueAutoPivotGrid = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));

    Map<String, dynamic> json = blueAutoPivotGrid.toJson();
    BlueAutoPivotGrid fromJson = BlueAutoPivotGrid.fromJson(json);

    expect(fromJson, blueAutoPivotGrid);
  });

  test('bad data replaced', () {
    List<List<bool>> badGrid = List.generate((4.02 / 0.2).ceil(),
        (index) => List.filled((14.54 / 0.2).ceil(), true));
    BlueAutoPivotGrid pivotGrid = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02), nodeSizeMeters: 0.2, blueAutoPivotGrid: badGrid);
    Map<String, dynamic> json = pivotGrid.toJson();
    json.remove('field_size');
    BlueAutoPivotGrid fromJson = BlueAutoPivotGrid.fromJson(json);

    expect(fromJson.fieldSize.width,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().width, 0.01));
    expect(fromJson.fieldSize.height,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().height, 0.01));
    expect(
        const DeepCollectionEquality().equals(badGrid, fromJson.blueAutoPivotGrid), false);
    for (var row in fromJson.blueAutoPivotGrid) {
      for (var node in row) {
        expect(node, false);
      }
    }
  });
}
