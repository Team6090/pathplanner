import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathplanner/pathfinding/limelight_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';

void main() {
  test('equals/hashCode', () {
    LimelightGrid grid1 = LimelightGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        limelightGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    LimelightGrid grid2 = LimelightGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        limelightGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    LimelightGrid grid3 = LimelightGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        limelightGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), true)));

    expect(grid2, grid1);
    expect(grid3, isNot(grid1));

    expect(grid3.hashCode, isNot(grid1.hashCode));
  });

  test('toJson/fromJson interoperability', () {
    LimelightGrid limelightGrid = LimelightGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        limelightGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));

    Map<String, dynamic> json = limelightGrid.toJson();
    LimelightGrid fromJson = LimelightGrid.fromJson(json);

    expect(fromJson, limelightGrid);
  });

  test('bad data replaced', () {
    List<List<bool>> badGrid = List.generate((4.02 / 0.2).ceil(),
        (index) => List.filled((14.54 / 0.2).ceil(), true));
    LimelightGrid limelightGrid = LimelightGrid(
        fieldSize: const Size(16.54, 8.02), nodeSizeMeters: 0.2, limelightGrid: badGrid);
    Map<String, dynamic> json = limelightGrid.toJson();
    json.remove('field_size');
    LimelightGrid fromJson = LimelightGrid.fromJson(json);

    expect(fromJson.fieldSize.width,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().width, 0.01));
    expect(fromJson.fieldSize.height,
        closeTo(FieldImage.defaultField.getFieldSizeMeters().height, 0.01));
    expect(
        const DeepCollectionEquality().equals(badGrid, fromJson.limelightGrid), false);
    for (var row in fromJson.limelightGrid) {
      for (var node in row) {
        expect(node, false);
      }
    }
  });
}
