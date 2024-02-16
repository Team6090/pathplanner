import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:pathplanner/widgets/field_image.dart';

class LimelightGrid {
  Size fieldSize;
  num nodeSizeMeters;
  List<List<bool>> limelightGrid;

  LimelightGrid({
    required this.fieldSize,
    required this.nodeSizeMeters,
    required this.limelightGrid,
  });

  LimelightGrid.blankGrid({
    required this.nodeSizeMeters,
    required this.fieldSize,
  }) : limelightGrid = [] {
    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    limelightGrid = List.generate(rows, (index) => List.filled(cols, false));
  }

  LimelightGrid.fromJson(Map<String, dynamic> json)
      : fieldSize = _sizeFromJson(json['field_size']),
        nodeSizeMeters = json['nodeSizeMeters'] ?? 0.2,
        limelightGrid = [] {
    limelightGrid = [
      for (var dynList in json['limelightgrid'] ?? [])
        (dynList as List<dynamic>).map((e) => e as bool).toList(),
    ];

    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    if (limelightGrid.isEmpty ||
        limelightGrid.length != rows ||
        limelightGrid[0].isEmpty ||
        limelightGrid[0].length != cols) {
      // LimelightGrid does not match what it should, replace it with an emptry limelightgrid
      limelightGrid = List.generate(rows, (index) => List.filled(cols, false));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'field_size': {
        'x': fieldSize.width,
        'y': fieldSize.height,
      },
      'nodeSizeMeters': nodeSizeMeters,
      'limelightgrid': limelightGrid,
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
      other is LimelightGrid &&
      other.runtimeType == runtimeType &&
      other.fieldSize == fieldSize &&
      other.nodeSizeMeters == nodeSizeMeters &&
      const DeepCollectionEquality().equals(other.limelightGrid, limelightGrid);

  @override
  int get hashCode => Object.hash(fieldSize, nodeSizeMeters, limelightGrid);
}
