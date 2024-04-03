
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MaskPreviewer extends StatelessWidget{
  final  Uint8List? imageBytes;

  const MaskPreviewer({super.key,required this.imageBytes});
  @override
  Widget build(BuildContext context) {
    double w= MediaQuery.of(context).size.width*0.9;
    double h= MediaQuery.of(context).size.height*0.4;

    if(imageBytes==null) return Container();
    return  Container(
        decoration: BoxDecoration(border:Border.all(width: 1,color: Colors.grey)),

        width: w,
        height: h,
        child: Center(
          child: Image.memory( imageBytes!,

            width: w,height: h,
            fit: BoxFit.fitWidth,
          ),
        ));
  }
}