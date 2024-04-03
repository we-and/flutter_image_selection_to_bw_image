
import 'package:flutter/material.dart';
import 'package:image_selection_to_bw_image/previewer/painters/image_painter.dart';

class ImageSelectionOverlay extends StatelessWidget{
  final   List<Offset> points ;
  const   ImageSelectionOverlay(this.points, {super.key});
  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: 0.7,
      child: CustomPaint(
        painter: OverlayImagePainter(points),
      ),
    );
  }
}