import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// If the image is already available, [hasImage] is true, and [width] and [height]
/// indicate the image dimensions.
///
/// If the image is not yet available, [hasImage] is false, and [width] and [height]
/// are null.
///
/// The functions [pixelColorAt] and [pixelColorAtAlignment] can be used to read the
/// color of the image pixels. If the coordinates point to outside of the image, or
/// if the image is not yet available, then these functions will return the
/// default-color provided in the [ImagePixels] constructor.
///
typedef BuilderFromImage = Widget Function({
  bool hasImage,
  int width,
  int height,
  ui.Image image,
  ByteData byteData,
  Color Function(int x, int y) pixelColorAt,
  Color Function(Alignment alignment) pixelColorAtAlignment,
});

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// The [ImagePixels] widget lets you define an image through an [imageProvider],
/// and then use a [builder] to build a child widget that depends on the image dimension
/// and the color of its pixels.
///
/// The default constructor lets you provide the [imageProvider], the [builder], and a
/// [defaultColor] to be used when reading pixels outside of the image (or while the
/// image is downloading).
///
/// The [ImagePixels.container] constructor creates a container with a background-color
/// that is the same color as the image pixel at the [colorAlignment] position.
///
class ImagePixels extends StatefulWidget {
  //
  final ImageProvider imageProvider;
  final Color defaultColor;
  final BuilderFromImage builder;

  ImagePixels({
    this.imageProvider,
    this.defaultColor = Colors.grey,
    this.builder,
  });

  /// Returns a container with the given [child].
  /// The background color of the container is given by the pixel in the [colorAlignment]
  /// position of the image pointed by the [imageProvider].
  ///
  ImagePixels.container({
    this.imageProvider,
    this.defaultColor = Colors.grey,
    Alignment colorAlignment,
    Widget child,
  }) : builder = _color(colorAlignment, child, defaultColor);

  static BuilderFromImage _color(
    Alignment colorAlignment,
    Widget child,
    Color defaultColor,
  ) =>
      ({
        bool hasImage,
        int width,
        int height,
        ui.Image image,
        ByteData byteData,
        Color Function(int x, int y) pixelColorAt,
        Color Function(Alignment alignment) pixelColorAtAlignment,
      }) =>
          Container(
            color: hasImage ? pixelColorAtAlignment(colorAlignment) : defaultColor,
            child: child,
          );

  @override
  _ImagePixelsState createState() => _ImagePixelsState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _ImagePixelsState extends State<ImagePixels> {
  //
  ui.Image image;
  ByteData byteData;
  int width;
  int height;

  ImageProvider get imageProvider => widget.imageProvider;

  Color get defaultColor => widget.defaultColor;

  @override
  void initState() {
    super.initState();
    if (imageProvider == null) return;
    _refreshImage();
  }

  @override
  void didUpdateWidget(ImagePixels oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (imageProvider != oldWidget.imageProvider) _refreshImage();
  }

  void _refreshImage() {
    //
    if (imageProvider == null) {
      _toByteData(null);
    }
    //
    else
      _GetImage(
          imageProvider: imageProvider,
          loadCallback: (ui.Image image) {
            setState(() {
              _toByteData(image);
            });
          }).run();
  }

  void _toByteData(ui.Image image) {
    //
    if (image == null) {
      this.image = null;
      byteData = null;
      width = null;
      height = null;
    }
    //
    else {
      Future(() async {
        this.image = image;
        width = image.width;
        height = image.height;
        byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        setState(() {});
      });
    }
  }

  /// Pixel coordinates: (0,0) → (width-1, height-1).
  Color pixelColorAt(int x, int y) {
    if (byteData == null ||
        width == null ||
        height == null ||
        x < 0 ||
        x >= width ||
        y < 0 ||
        y >= height)
      return defaultColor;
    else {
      var byteOffset = 4 * (x + (y * width));
      return _colorAtByteOffset(byteOffset);
    }
  }

  /// Pixel coordinates: (-1, -1) → (1, 1).
  Color pixelColorAtAlignment(Alignment alignment) {
    if (byteData == null ||
        width == null ||
        height == null ||
        alignment == null ||
        alignment.x < -1.0 ||
        alignment.x > 1.0 ||
        alignment.y < -1.0 ||
        alignment.y > 1.0) return defaultColor;

    Offset offset = alignment.alongSize(Size(width.toDouble() - 1.0, height.toDouble() - 1.0));
    return pixelColorAt(offset.dx.round(), offset.dy.round());
  }

  Color _colorAtByteOffset(int byteOffset) => Color(_rgbaToArgb(byteData.getUint32(byteOffset)));

  int _rgbaToArgb(int rgbaColor) {
    int a = rgbaColor & 0xFF;
    int rgb = rgbaColor >> 8;
    return rgb + (a << 24);
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        hasImage: width != null,
        width: width,
        height: height,
        pixelColorAt: pixelColorAt,
        pixelColorAtAlignment: pixelColorAtAlignment,
      );
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// Calls the provided [loadCallback] with the image.
/// The image will come from Flutter's image cache, if present.
/// Otherwise, retrieves the image and puts it into the cache.
///
class _GetImage {
  //
  _GetImage({
    @required this.imageProvider,
    @required this.loadCallback,
  })  : assert(imageProvider != null),
        assert(loadCallback != null);

  final ImageProvider imageProvider;

  final void Function(ui.Image) loadCallback;

  void run() {
    //
    var decoder = (Uint8List bytes, {bool allowUpscaling, int cacheWidth, int cacheHeight}) =>
        PaintingBinding.instance
            .instantiateImageCodec(bytes, cacheWidth: cacheWidth, cacheHeight: cacheHeight);

    final ImageStreamCompleter completer = PaintingBinding.instance.imageCache.putIfAbsent(
      imageProvider, // key
      // ignore: invalid_use_of_protected_member
      () => imageProvider.load(imageProvider, decoder), // loader
      onError: null,
    );

    ImageListener onImage = (ImageInfo image, bool synchronousCall) {
      if (loadCallback != null) loadCallback(image.image);
    };

    ImageStreamListener listener = ImageStreamListener(onImage);

    completer.addListener(listener);
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
