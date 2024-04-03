
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_selection_to_bw_image/image_painter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageEditor extends StatefulWidget {
  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  List<Offset> points = []; // Stores the positions where the user taps/swipes
  String url = 'https://as2.ftcdn.net/v2/jpg/00/97/58/97/1000_F_97589769_t45CqXyzjz0KXwoBZT9PRaWGHRk5hQqQ.jpg';
  int width = 820;
  int height = 542;

  Image? bwimage;
  Uint8List? imageBytes;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(height: 50,width: 10,),
          Text("Original image for the areas to be selected:"),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  points.add(details.localPosition);
                });

              },
              onPanEnd: (d){
                process();
              },
              onTapDown: (details) {
                setState(() {
                  points.add(details.localPosition);
                });
              },
              child: Stack(children: [

                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child:    Image.network(
                      url,
                      fit: BoxFit.contain,
                    )),
                Opacity(opacity: 0.7,
                  child: CustomPaint(
                    painter: ImagePainter(points),
                  ),
                ),
              ]),
            ),
          ),
          Text("Saved image to be sent to server:"),
          if(imageBytes!=null)
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: Image.memory( imageBytes!,
                  fit: BoxFit.fill,
                )),
          if(false)
            TextButton(
              child: Text('Convert to B&W with Red Overlays'),
              onPressed: () async {
                process();
                //saveImageToDisk(bwimage, 'bw.jpg');
                // Implement the conversion logic here.
                // This is a complex process that might involve image processing libraries to manipulate the pixels based on the overlay positions.
              },
            ),
        ],
      ),
    );
  }
  process() async {
    print("convert");
    final img.Image bwimage1 = await convertToBlackAndWhiteWithCircles(width, height, points);
    print("encode");

    Uint8List imageBytes1 = encodeImageToUint8List(bwimage1);
    print("update");

    setState(() {
      imageBytes=imageBytes1;
    });
  }
  Uint8List encodeImageToUint8List(img.Image image, {String format = 'png'}) {
    print("encodeImageToUint8List");
    List<int> bytes;
    if (format == 'png') {
      bytes = img.encodePng(image);
    } else { // Defaults to JPEG if not PNG
      bytes = img.encodeJpg(image);
    }
    return Uint8List.fromList(bytes);
  }
  Future<String> saveImageToDisk(img.Image image, String filename) async {
    try {
      // if (Platform.isAndroid) PathProviderAndroid.registerWith();
      // if (Platform.isIOS) PathProviderIOS.registerWith();

      // Get the directory to save the image
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$filename';

      // Encode the image to JPEG format (you can change it to PNG if you prefer)
      final imageBytes = img.encodeJpg(image);

      // Write the image bytes to a file
      File file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      print(imagePath);
      return imagePath; // Return the path where the image was saved
    } catch (e) {
      print("Error saving image: $e");
      throw Exception("Failed to save image");
    }
  }

  Future<img.Image> convertToBlackAndWhiteWithCircles(int width, int height, List<Offset> circleCenters) async {
    print("w="+width.toString());
    print("h="+height.toString());
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
