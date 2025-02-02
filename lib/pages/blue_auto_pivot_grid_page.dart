import 'dart:convert';
import 'dart:math';

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:path/path.dart';
import 'package:pathplanner/pathfinding/blue_auto_pivot_grid.dart';
import 'package:pathplanner/widgets/field_image.dart';
import 'package:pathplanner/util/path_painter_util.dart';
import 'package:pathplanner/widgets/number_text_field.dart';

class BlueAutoPivotGridPage extends StatefulWidget {
  final Directory deployDirectory;
  final FieldImage fieldImage;
  final FileSystem fs;

  const BlueAutoPivotGridPage({
    super.key,
    required this.deployDirectory,
    required this.fs,
    required this.fieldImage,
  });

  @override
  State<BlueAutoPivotGridPage> createState() => _BlueAutoPivotGridPageState();
}

class _BlueAutoPivotGridPageState extends State<BlueAutoPivotGridPage> {
  bool _loading = true;
  bool _adding = true;
  late BlueAutoPivotGrid _grid;

  @override
  void initState() {
    super.initState();

    File gridFile =
        widget.fs.file(join(widget.deployDirectory.path, 'blueautopivotgrid.json'));
    gridFile.exists().then((value) async {
      if (value) {
        String fileContent = gridFile.readAsStringSync();
        Map<String, dynamic> json = jsonDecode(fileContent);
        setState(() {
          _grid = BlueAutoPivotGrid.fromJson(json);
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        Center(
          child: InteractiveViewer(
            child: GestureDetector(
              onTapUp: (details) {
                double x = _xPixelsToMeters(details.localPosition.dx);
                double y = _yPixelsToMeters(details.localPosition.dy);

                int row = (y / _grid.nodeSizeMeters).floor();
                int col = (x / _grid.nodeSizeMeters).floor();

                if (row >= 0 &&
                    row < _grid.blueAutoPivotGrid.length &&
                    col >= 0 &&
                    col < _grid.blueAutoPivotGrid[row].length) {
                  setState(() {
                    _grid.blueAutoPivotGrid[row][col] = !_grid.blueAutoPivotGrid[row][col];
                  });

                  _saveBlueAutoPivotGrid();
                }
              },
              onPanStart: (details) {
                double x = _xPixelsToMeters(details.localPosition.dx);
                double y = _yPixelsToMeters(details.localPosition.dy);

                int row = (y / _grid.nodeSizeMeters).floor();
                int col = (x / _grid.nodeSizeMeters).floor();

                if (row >= 0 &&
                    row < _grid.blueAutoPivotGrid.length &&
                    col >= 0 &&
                    col < _grid.blueAutoPivotGrid[row].length) {
                  _adding = !_grid.blueAutoPivotGrid[row][col];
                }
              },
              onPanUpdate: (details) {
                double x = _xPixelsToMeters(details.localPosition.dx);
                double y = _yPixelsToMeters(details.localPosition.dy);

                int row = (y / _grid.nodeSizeMeters).floor();
                int col = (x / _grid.nodeSizeMeters).floor();

                if (row >= 0 &&
                    row < _grid.blueAutoPivotGrid.length &&
                    col >= 0 &&
                    col < _grid.blueAutoPivotGrid[row].length) {
                  setState(() {
                    _grid.blueAutoPivotGrid[row][col] = _adding;
                  });
                }
              },
              onPanEnd: (_) {
                _saveBlueAutoPivotGrid();
              },
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Stack(
                  children: [
                    widget.fieldImage.getWidget(),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _NavigationPainter(
                          fieldImage: widget.fieldImage,
                          blueAutoPivotGrid: _grid.blueAutoPivotGrid,
                          nodeSizeMeters: _grid.nodeSizeMeters,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton.extended(
              label: const Text('Edit Grid'),
              icon: const Icon(Icons.edit),
              onPressed: _showEditDialog,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog() {
    TextEditingController nodeSizeController = TextEditingController();
    TextEditingController fieldLengthController = TextEditingController();
    TextEditingController fieldWidthController = TextEditingController();

    showDialog(
      context: this.context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Grid'),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: NumberTextField(
                      initialText: _grid.nodeSizeMeters.toStringAsFixed(2),
                      label: 'Node Size (M)',
                      arrowKeyIncrement: 0.05,
                      controller: nodeSizeController,
                    )),
                  ],
                ),
                const Text(
                    'Larger node size = more performance, but less accuracy'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: NumberTextField(
                      initialText: _grid.fieldSize.width.toStringAsFixed(2),
                      label: 'Field Length (M)',
                      arrowKeyIncrement: 0.01,
                      controller: fieldLengthController,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: NumberTextField(
                      initialText: _grid.fieldSize.height.toStringAsFixed(2),
                      label: 'Field Width (M)',
                      arrowKeyIncrement: 0.01,
                      controller: fieldWidthController,
                    )),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                    'Note: Changing these attributes will clear the Pivot Grid. This cannot be undone.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String fileContent = await DefaultAssetBundle.of(this.context)
                    .loadString('resources/default_blueautopivotgrid.json');

                setState(() {
                  _grid = BlueAutoPivotGrid.fromJson(jsonDecode(fileContent));
                });
                _saveBlueAutoPivotGrid();

                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Restore Default'),
            ),
            TextButton(
              onPressed: () {
                if (nodeSizeController.text.isNotEmpty &&
                    fieldLengthController.text.isNotEmpty &&
                    fieldWidthController.text.isNotEmpty) {
                  num nodeSize = nodeSizeController.text.interpret();
                  num fieldLength = fieldLengthController.text.interpret();
                  num fieldWidth = fieldWidthController.text.interpret();

                  setState(() {
                    _grid = BlueAutoPivotGrid.blankGrid(
                      nodeSizeMeters: nodeSize,
                      fieldSize:
                          Size(fieldLength.toDouble(), fieldWidth.toDouble()),
                    );
                  });
                  _saveBlueAutoPivotGrid();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  double _xPixelsToMeters(double pixels) {
    return ((pixels - 48) / _NavigationPainter.scale) /
        widget.fieldImage.pixelsPerMeter;
  }

  double _yPixelsToMeters(double pixels) {
    return (widget.fieldImage.defaultSize.height -
            ((pixels - 48) / _NavigationPainter.scale)) /
        widget.fieldImage.pixelsPerMeter;
  }

  void _saveBlueAutoPivotGrid() {
    widget.fs
        .file(join(widget.deployDirectory.path, 'blueautopivotgrid.json'))
        .writeAsString(jsonEncode(_grid));
  }
}

class _NavigationPainter extends CustomPainter {
  final FieldImage fieldImage;

  final num nodeSizeMeters;
  final List<List<bool>> blueAutoPivotGrid;

  static double scale = 1;

  _NavigationPainter({
    required this.fieldImage,
    required this.blueAutoPivotGrid,
    required this.nodeSizeMeters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    scale = size.width / fieldImage.defaultSize.width;

    var outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey[600]!
      ..strokeWidth = 1;
    var fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red.withOpacity(0.4);

    for (int row = 0; row < blueAutoPivotGrid.length; row++) {
      for (int col = 0; col < blueAutoPivotGrid[row].length; col++) {
        Offset tl = PathPainterUtil.pointToPixelOffset(
            Point(col * nodeSizeMeters, row * nodeSizeMeters),
            scale,
            fieldImage);
        Offset br = PathPainterUtil.pointToPixelOffset(
            Point((col + 1) * nodeSizeMeters, (row + 1) * nodeSizeMeters),
            scale,
            fieldImage);

        if (blueAutoPivotGrid[row][col]) {
          canvas.drawRect(Rect.fromPoints(tl, br), fillPaint);
        }
        canvas.drawRect(Rect.fromPoints(tl, br), outlinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
