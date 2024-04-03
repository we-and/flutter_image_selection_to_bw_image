
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget{
  final String imageUrl;

  const ImageViewer({super.key,required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    double w= MediaQuery.of(context).size.width*0.9;
    double h= MediaQuery.of(context).size.height*0.4;
    return  Container(
      decoration: BoxDecoration(border:Border.all(width: 1,color: Colors.grey)),
        width: w,
        height: h,
        child:    Image.network(
          imageUrl,
          width: w,height: h,
          fit: BoxFit.fitWidth,
        ));
  }
}