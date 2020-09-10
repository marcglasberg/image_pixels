import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImagePixels Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ImagePixels Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AssetImage angular = AssetImage("lib/images/AngularLogo.jpg");
  final AssetImage flutter = AssetImage("lib/images/FlutterLogo.jpg");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              //
              // 1) This uses the `ImagePixels.container` constructor.
              // It's used to extend the background-color of an image.
              child: ImagePixels.container(
                imageProvider: flutter,
                child: Container(
                  alignment: Alignment.center,
                  child: Container(width: 100, child: Image(image: flutter)),
                ),
              ),
            ),
            //
            //
            Expanded(
              //
              // 2) This uses the plain `ImagePixels` constructor.
              // It gives you a lot more control, and complete access
              // to the image's width/height and pixels.
              child: ImagePixels(
                imageProvider: angular,
                builder: (BuildContext context, ImgDetails img) {
                  return Container(
                    color: img.pixelColorAtAlignment(Alignment.topLeft),
                    alignment: Alignment.center,
                    child: Stack(
                      overflow: Overflow.visible,
                      children: [
                        Container(
                          width: 100,
                          child: Image(image: angular),
                        ),
                        Positioned(
                          bottom: -30,
                          right: 0,
                          left: 0,
                          child: Text(
                            "Size: ${img.width} × ${img.height}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
