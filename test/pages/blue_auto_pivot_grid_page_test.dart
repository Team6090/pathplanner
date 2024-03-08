import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:pathplanner/pages/blue_auto_pivot_grid_page.dart';
import 'package:pathplanner/pathfinding/blue_auto_pivot_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';
import 'package:pathplanner/widgets/number_text_field.dart';

void main() {
  late MemoryFileSystem fs;
  final String deployPath = Platform.isWindows ? 'C:\\deploy' : '/deploy';

  setUp(() => fs = MemoryFileSystem(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix));

  testWidgets('loading when no file', (widgetTester) async {
    fs.directory(deployPath).createSync(recursive: true);

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BlueAutoPivotGridPage(
          deployDirectory: fs.directory(deployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('blueautopivotgrid editor shows when file', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(deployPath).createSync(recursive: true);
    BlueAutoPivotGrid blueAutoPivotGrid = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(deployPath, 'blueautopivotgrid.json'))
        .writeAsStringSync(jsonEncode(blueAutoPivotGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BlueAutoPivotGridPage(
          deployDirectory: fs.directory(deployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.image(FieldImage.defaultField.image.image), findsOneWidget);
  });

  testWidgets('blueautopivotgrid editor tap', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(deployPath).createSync(recursive: true);
    BlueAutoPivotGrid blueAutoPivotGrid = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(deployPath, 'blueautopivotgrid.json'))
        .writeAsStringSync(jsonEncode(blueAutoPivotGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BlueAutoPivotGridPage(
          deployDirectory: fs.directory(deployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pump();

    await widgetTester.tapAt(const Offset(200, 200));
    await widgetTester.pump();

    BlueAutoPivotGrid editedGrid = BlueAutoPivotGrid.fromJson(jsonDecode(
        fs.file(join(deployPath, 'blueautopivotgrid.json')).readAsStringSync()));
    expect(editedGrid, isNot(blueAutoPivotGrid));
  });

  testWidgets('blueautopivotgrid editor drag', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(deployPath).createSync(recursive: true);
    BlueAutoPivotGrid blueAutoPivotGrid = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(deployPath, 'blueautopivotgrid.json'))
        .writeAsStringSync(jsonEncode(blueAutoPivotGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BlueAutoPivotGridPage(
          deployDirectory: fs.directory(deployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pump();

    var gesture = await widgetTester.startGesture(const Offset(200, 200),
        kind: PointerDeviceKind.mouse);
    addTearDown(() => gesture.removePointer());
    await widgetTester.pump();
    for (int i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(10, 0));
      await widgetTester.pump();
    }
    await gesture.up();
    await widgetTester.pump();

    BlueAutoPivotGrid editedGrid = BlueAutoPivotGrid.fromJson(jsonDecode(
        fs.file(join(deployPath, 'blueautopivotgrid.json')).readAsStringSync()));
    expect(editedGrid, isNot(blueAutoPivotGrid));
  });

  testWidgets('edit blueautopivotGrid attributes', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(deployPath).createSync(recursive: true);
    BlueAutoPivotGrid blueAutoPivotGrid = BlueAutoPivotGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        blueAutoPivotGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(deployPath, 'blueautopivotgrid.json'))
        .writeAsStringSync(jsonEncode(blueAutoPivotGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BlueAutoPivotGridPage(
          deployDirectory: fs.directory(deployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await widgetTester.tap(fab);

    await widgetTester.pumpAndSettle();

    final nodeSizeField = find.widgetWithText(NumberTextField, 'Node Size (M)');

    expect(nodeSizeField, findsOneWidget);

    await widgetTester.enterText(nodeSizeField, '0.4');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.tap(find.text('Confirm'));
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(fab);
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.text('Restore Default'));
    await widgetTester.pumpAndSettle();
  });
}
