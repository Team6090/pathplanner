import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:pathplanner/widgets/field_image.dart';

class BlueAutoPivotGrid {
  Size fieldSize;
  num nodeSizeMeters;
  List<List<bool>> blueAutoPivotGrid;

  BlueAutoPivotGrid({
    required this.fieldSize,
    required this.nodeSizeMeters,
    required this.blueAutoPivotGrid,
  });

  BlueAutoPivotGrid.blankGrid({
    required this.nodeSizeMeters,
    required this.fieldSize,
  }) : blueAutoPivotGrid = [] {
    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    blueAutoPivotGrid = List.generate(rows, (index) => List.filled(cols, false));
  }

  BlueAutoPivotGrid.fromJson(Map<String, dynamic> json)
      : fieldSize = _sizeFromJson(json['field_size']),
        nodeSizeMeters = json['nodeSizeMeters'] ?? 0.2,
        blueAutoPivotGrid = [] {
    blueAutoPivotGrid = [
      for (var dynList in json['blueAutoPivotGrid'] ?? [])
        (dynList as List<dynamic>).map((e) => e as bool).toList(),
    ];

    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    if (blueAutoPivotGrid.isEmpty ||
        blueAutoPivotGrid.length != rows ||
        blueAutoPivotGrid[0].isEmpty ||
        blueAutoPivotGrid[0].length != cols) {
      // Grid does not match what it should, replace it with an emptry grid
      blueAutoPivotGrid = List.generate(rows, (index) => List.filled(cols, false));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'field_size': {
        'x': fieldSize.width,
        'y': fieldSize.height,
      },
      'nodeSizeMeters': nodeSizeMeters,
      'blueAutoPivotGrid': blueAutoPivotGrid,
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
      other is BlueAutoPivotGrid &&
      other.runtimeType == runtimeType &&
      other.fieldSize == fieldSize &&
      other.nodeSizeMeters == nodeSizeMeters &&
      const DeepCollectionEquality().equals(other.blueAutoPivotGrid, blueAutoPivotGrid);

  @override
  int get hashCode => Object.hash(fieldSize, nodeSizeMeters, blueAutoPivotGrid);
}
