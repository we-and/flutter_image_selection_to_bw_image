import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_selection_to_bw_image/previewer/entities/image_details.dart';
import 'package:image_selection_to_bw_image/previewer/painters/image_painter.dart';
import 'package:image_selection_to_bw_image/previewer/widgets/image_viewer.dart';
import 'package:image_selection_to_bw_image/previewer/widgets/mask_viewer.dart';
import 'package:image_selection_to_bw_image/previewer/widgets/selection_overlay.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class MaskPreviewerPage extends StatefulWidget {
  const MaskPreviewerPage({super.key});

  @override
  _MaskPreviewerPageState createState() => _MaskPreviewerPageState();
}

class _MaskPreviewerPageState extends State<MaskPreviewerPage> {
  List<Offset> points = []; // Stores the positions where the user taps/swipes

  final imageDetails = ImageDetails('https://thumbs.dreamstime.com/b/newfoundland-dog-front-white-background-12485381.jpg', 586, 558);

  Image? maskImage;
  Uint8List? maskImageBytes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
              width: 10,
            ),
            Text("Original image for the areas to be selected:"),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    points.add(details.localPosition);
                  });
                },
                onPanEnd: (d) {
                  process();
                },
                onTapDown: (details) {
                  setState(() {
                    points.add(details.localPosition);
                  });
                },
                child: Stack(children: [ImageViewer(imageUrl: imageDetails.url), ImageSelectionOverlay(points)]),
              ),
            ),
            Text("Saved image to be sent to server:"),
            MaskPreviewer(imageBytes: maskImageBytes)
          ],
        ),
      ),
    );
  }

  process() async {
    final img.Image bwimage1 = await convertToBlackAndWhiteWithCircles(imageDetails.width, imageDetails.height, points);
    Uint8List imageBytes1 = encodeImageToUint8List(bwimage1);

    setState(() {
      maskImageBytes = imageBytes1;
    });
  }

  Uint8List encodeImageToUint8List(img.Image image, {String format = 'png'}) {
    List<int> bytes;
    if (format == 'png') {
      bytes = img.encodePng(image);
    } else {
      // Defaults to JPEG if not PNG
      bytes = img.encodeJpg(image);
    }
    return Uint8List.fromList(bytes);
  }

  Future<String> saveMaskImageToDisk(img.Image image, String filename) async {
    try {
      // Get the directory to save the image
      final directory = await getApplicationDocumentsDirectory();
      final maskImagePath = '${directory.path}/$filename';

      // Encode the image to JPEG format (you can change it to PNG if you prefer)
      final imageBytes = img.encodeJpg(image);

      // Write the image bytes to a file
      File file = File(maskImagePath);
      await file.writeAsBytes(imageBytes);

      print("Saved to" + maskImagePath);
      return maskImagePath; // Return the path where the image was saved
    } catch (e) {
      print("Error saving image: $e");
      throw Exception("Failed to save image");
    }
  }

  Future<img.Image> convertToBlackAndWhiteWithCircles(int width, int height, List<Offset> circleCenters) async {
    // Load the image
    img.Image image = img.Image(width, height);
    img.fill(image, img.getColor(0, 0, 0, 255)); // Fill the image with black

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Draw white circles
    for (var center in circleCenters) {
      img.fillCircle(image, center.dx.toInt(), center.dy.toInt(), 10, img.getColor(255, 255, 255, 255));
    }

    // Convert to black and white
    img.grayscale(image);

    // Optionally, you can further adjust the pixels where the circles were drawn to be pure white if the grayscale effect isn't satisfactory
    // This would involve another loop similar to the circle drawing, but ensuring those pixels are set to pure white.

    return image;
  }
}
