import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:pathplanner/widgets/field_image.dart';

class NavGrid {
  Size fieldSize;
  num nodeSizeMeters;
  List<List<bool>> navGrid;

  NavGrid({
    required this.fieldSize,
    required this.nodeSizeMeters,
    required this.navGrid,
  });

  NavGrid.blankGrid({
    required this.nodeSizeMeters,
    required this.fieldSize,
  }) : navGrid = [] {
    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    navGrid = List.generate(rows, (index) => List.filled(cols, false));
  }

  NavGrid.fromJson(Map<String, dynamic> json)
      : fieldSize = _sizeFromJson(json['field_size']),
        nodeSizeMeters = json['nodeSizeMeters'] ?? 0.2,
        navGrid = [] {
    navGrid = [
      for (var dynList in json['navGrid'] ?? [])
        (dynList as List<dynamic>).map((e) => e as bool).toList(),
    ];

    int rows = (fieldSize.height / nodeSizeMeters).ceil();
    int cols = (fieldSize.width / nodeSizeMeters).ceil();

    if (navGrid.isEmpty ||
        navGrid.length != rows ||
        navGrid[0].isEmpty ||
        navGrid[0].length != cols) {
      // Grid does not match what it should, replace it with an emptry navGrid
      navGrid = List.generate(rows, (index) => List.filled(cols, false));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'field_size': {
        'x': fieldSize.width,
        'y': fieldSize.height,
      },
      'nodeSizeMeters': nodeSizeMeters,
      'navGrid': navGrid,
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
      other is NavGrid &&
      other.runtimeType == runtimeType &&
      other.fieldSize == fieldSize &&
      other.nodeSizeMeters == nodeSizeMeters &&
      const DeepCollectionEquality().equals(other.navGrid, navGrid);

  @override
  int get hashCode => Object.hash(fieldSize, nodeSizeMeters, navGrid);
}
