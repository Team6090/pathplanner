import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:pathplanner/pages/nav_grid_page.dart';
import 'package:pathplanner/pathfinding/nav_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';
import 'package:pathplanner/widgets/number_text_field.dart';

void main() {
  late MemoryFileSystem fs;
  final String navDeployPath = Platform.isWindows ? 'C:\\deploy' : '/deploy';

  setUp(() => fs = MemoryFileSystem(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix));

  testWidgets('loading when no file', (widgetTester) async {
    fs.directory(navDeployPath).createSync(recursive: true);

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NavGridPage(
          deployDirectory: fs.directory(navDeployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('navgrid editor shows when file', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(navDeployPath).createSync(recursive: true);
    NavGrid navGrid = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(navDeployPath, 'navgrid.json'))
        .writeAsStringSync(jsonEncode(navGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NavGridPage(
          deployDirectory: fs.directory(navDeployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.image(FieldImage.defaultField.image.image), findsOneWidget);
  });

  testWidgets('navgrid editor tap', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(navDeployPath).createSync(recursive: true);
    NavGrid navGrid = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(navDeployPath, 'navgrid.json'))
        .writeAsStringSync(jsonEncode(navGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NavGridPage(
          deployDirectory: fs.directory(navDeployPath),
          fs: fs,
          fieldImage: FieldImage.defaultField,
        ),
      ),
    ));
    await widgetTester.pump();

    await widgetTester.tapAt(const Offset(200, 200));
    await widgetTester.pump();

    NavGrid editedGrid = NavGrid.fromJson(jsonDecode(
        fs.file(join(navDeployPath, 'navgrid.json')).readAsStringSync()));
    expect(editedGrid, isNot(navGrid));
  });

  testWidgets('navgrid editor drag', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(navDeployPath).createSync(recursive: true);
    NavGrid navGrid = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(navDeployPath, 'navgrid.json'))
        .writeAsStringSync(jsonEncode(navGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NavGridPage(
          deployDirectory: fs.directory(navDeployPath),
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

    NavGrid editedGrid = NavGrid.fromJson(jsonDecode(
        fs.file(join(navDeployPath, 'navgrid.json')).readAsStringSync()));
    expect(editedGrid, isNot(navGrid));
  });

  testWidgets('edit navGrid attributes', (widgetTester) async {
    var fs = MemoryFileSystem();
    fs.directory(navDeployPath).createSync(recursive: true);
    NavGrid navGrid = NavGrid(
        fieldSize: const Size(16.54, 8.02),
        nodeSizeMeters: 0.2,
        navGrid: List.generate((8.02 / 0.2).ceil(),
            (index) => List.filled((16.54 / 0.2).ceil(), false)));
    fs
        .file(join(navDeployPath, 'navgrid.json'))
        .writeAsStringSync(jsonEncode(navGrid));

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NavGridPage(
          deployDirectory: fs.directory(navDeployPath),
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
