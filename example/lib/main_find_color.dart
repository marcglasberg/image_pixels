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
      home: const MyHomePage(title: 'Find color demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AssetImage flutter = const AssetImage("lib/images/FlutterLogo.jpg");

  Offset localPosition = const Offset(-1, -1);
  Color color = const Color(0x00000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            const Expanded(
              flex: 1,
              child: Center(
                child: Text('Tap the image to see the pixel color:'),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Container(
                    color: Colors.grey,
                    child: Listener(
                      onPointerMove: (PointerMoveEvent details) {
                        setState(() {
                          localPosition = details.localPosition;
                        });
                      },
                      onPointerDown: (PointerDownEvent details) {
                        setState(() {
                          localPosition = details.localPosition;
                        });
                      },
                      child: ImagePixels(
                        imageProvider: flutter,
                        builder: (BuildContext context, ImgDetails img) {
                          var color = img.pixelColorAt!(
                            localPosition.dx.toInt(),
                            localPosition.dy.toInt(),
                          );

                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            if (mounted)
                              setState(() {
                                if (color != this.color) this.color = color;
                              });
                          });

                          return SizedBox(
                            width: 150,
                            height: 213,
                            child: Image(image: flutter),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(width: 75, height: 55, color: color),
                  Container(height: 20),
                  Text(localPosition.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
