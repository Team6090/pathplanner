import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:pathplanner/widgets/field_image.dart';

class PivotGrid {
  Size fieldSize;
  num nodeSizeMeters;
  List<List<bool>> pivotGrid;

  PivotGrid({
    required this.fieldSize,
    required this.nodeSizeMeters,
    required this.pivotGrid,
  });

  PivotGrid.blankGrid({
    required this.nodeSizeMeters,
    required this.fieldSize,
  }) : pivotGrid = [] {
    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    pivotGrid = List.generate(rows, (index) => List.filled(cols, false));
  }

  PivotGrid.fromJson(Map<String, dynamic> json)
      : fieldSize = _sizeFromJson(json['field_size']),
        nodeSizeMeters = json['nodeSizeMeters'] ?? 0.2,
        pivotGrid = [] {
    pivotGrid = [
      for (var dynList in json['pivotGrid'] ?? [])
        (dynList as List<dynamic>).map((e) => e as bool).toList(),
    ];

    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    if (pivotGrid.isEmpty ||
        pivotGrid.length != rows ||
        pivotGrid[0].isEmpty ||
        pivotGrid[0].length != cols) {
      // Grid does not match what it should, replace it with an emptry grid
      pivotGrid = List.generate(rows, (index) => List.filled(cols, false));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'field_size': {
        'x': fieldSize.width,
        'y': fieldSize.height,
      },
      'nodeSizeMeters': nodeSizeMeters,
      'pivotGrid': pivotGrid,
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
      other is PivotGrid &&
      other.runtimeType == runtimeType &&
      other.fieldSize == fieldSize &&
      other.nodeSizeMeters == nodeSizeMeters &&
      const DeepCollectionEquality().equals(other.pivotGrid, pivotGrid);

  @override
  int get hashCode => Object.hash(fieldSize, nodeSizeMeters, pivotGrid);
}
