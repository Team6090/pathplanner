import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:pathplanner/widgets/field_image.dart';

class RedAutoPivotGrid {
  Size fieldSize;
  num nodeSizeMeters;
  List<List<bool>> redAutoPivotGrid;

  RedAutoPivotGrid({
    required this.fieldSize,
    required this.nodeSizeMeters,
    required this.redAutoPivotGrid,
  });

  RedAutoPivotGrid.blankGrid({
    required this.nodeSizeMeters,
    required this.fieldSize,
  }) : redAutoPivotGrid = [] {
    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    redAutoPivotGrid = List.generate(rows, (index) => List.filled(cols, false));
  }

  RedAutoPivotGrid.fromJson(Map<String, dynamic> json)
      : fieldSize = _sizeFromJson(json['field_size']),
        nodeSizeMeters = json['nodeSizeMeters'] ?? 0.2,
        redAutoPivotGrid = [] {
    redAutoPivotGrid = [
      for (var dynList in json['redAutoPivotGrid'] ?? [])
        (dynList as List<dynamic>).map((e) => e as bool).toList(),
    ];

    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    if (redAutoPivotGrid.isEmpty ||
        redAutoPivotGrid.length != rows ||
        redAutoPivotGrid[0].isEmpty ||
        redAutoPivotGrid[0].length != cols) {
      // Grid does not match what it should, replace it with an emptry grid
      redAutoPivotGrid = List.generate(rows, (index) => List.filled(cols, false));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'field_size': {
        'x': fieldSize.width,
        'y': fieldSize.height,
      },
      'nodeSizeMeters': nodeSizeMeters,
      'redAutoPivotGrid': redAutoPivotGrid,
    };
  }

  static Size _sizeFromJson(Map<String, dynamic>? sizeJson) {
    if (sizeJson == null || sizeJson['x'] == null || sizeJson['y'] == null) {
      return FieldImage.defaultField.getFieldSizeMeters();
    }
    return Size(
        (sizeJson['x'] as num).toDouble(), (sizeJson['y'] as num).toDouble());
  }

  @override
  bool operator ==(Object other) =>
      other is RedAutoPivotGrid &&
      other.runtimeType == runtimeType &&
      other.fieldSize == fieldSize &&
      other.nodeSizeMeters == nodeSizeMeters &&
      const DeepCollectionEquality().equals(other.redAutoPivotGrid, redAutoPivotGrid);

  @override
  int get hashCode => Object.hash(fieldSize, nodeSizeMeters, redAutoPivotGrid);
}
