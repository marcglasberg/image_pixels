import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

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
typedef BuilderFromImage = Widget Function(BuildContext context, ImgDetails img);

// /////////////////////////////////////////////////////////////////////////////////////////////////

///
class ImgDetails {
  //

  /// The width (number of pixels) of the original image.
  final int? width;

  /// The height (number of pixels) of the original image.
  final int? height;

  /// Returns the pixel color from its coordinates:
  /// (0,0) top-left; To (width-1, height-1) bottom-right.
  final Color Function(int x, int y)? pixelColorAt;

  /// Returns the pixel color from its coordinates:
  /// (-1, -1) top-left; To (1, 1) bottom-right.
  final Color Function(Alignment alignment)? pixelColorAtAlignment;

  /// The image itself, as a ui.Image.
  /// Usually you should not read from the image directly, but through
  /// the helper methods `pixelColorAt` and `pixelColorAtAlignment`.
  final ui.Image? uiImage;

  /// The image itself as a ByteData.
  /// Usually you should not read from the image directly, but through
  /// the helper methods `pixelColorAt` and `pixelColorAtAlignment`.
  final ByteData? byteData;

  /// Returns true when the image is downloaded and available.
  bool get hasImage => uiImage != null;

  ImgDetails({
    this.width,
    this.height,
    this.uiImage,
    this.byteData,
    this.pixelColorAt,
    this.pixelColorAtAlignment,
  });
}

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
  final ImageProvider? imageProvider;
  final Color defaultColor;
  final BuilderFromImage builder;

  /// Lets you provide the [imageProvider], the [builder], as well as a
  /// [defaultColor] to be used when reading pixels outside the image (or
  /// while the image is downloading). If [imageProvider] is null, the
  /// image will be empty and it will all be painted with the [defaultColor].
  ImagePixels({
    required this.imageProvider,
    this.defaultColor = Colors.grey,
    required this.builder,
  });

  /// Returns a container with the given [child].
  /// The background color of the container is given by the pixel in the
  /// [colorAlignment] position of the image pointed by the [imageProvider].
  /// The [defaultColor] will be used for pixels outside the image (or
  /// while the image is downloading). If [imageProvider] is null, the
  /// image will be empty and it will all be painted with the [defaultColor].
  ImagePixels.container({
    required this.imageProvider,
    this.defaultColor = Colors.grey,
    Alignment colorAlignment = Alignment.topLeft,
    Widget? child,
  }) : builder = _color(colorAlignment, child, defaultColor);

  static BuilderFromImage _color(
    Alignment colorAlignment,
    Widget? child,
    Color defaultColor,
  ) =>
      (context, img) => Container(
            color: img.hasImage ? img.pixelColorAtAlignment!(colorAlignment) : defaultColor,
            child: child,
          );

  @override
  _ImagePixelsState createState() => _ImagePixelsState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _ImagePixelsState extends State<ImagePixels> {
  //
  ui.Image? image;
  ByteData? byteData;
  int? width;
  int? height;

  ImageProvider? get imageProvider => widget.imageProvider;

  Color get defaultColor => widget.defaultColor;

  @override
  void initState() {
    super.initState();
    if (imageProvider == null) return;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshImage();
    });
  }

  @override
  void didUpdateWidget(ImagePixels oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (imageProvider != oldWidget.imageProvider) _refreshImage();
  }

  void _refreshImage() {
    //
    var _imageProvider = imageProvider;

    if (_imageProvider == null) {
      _toByteData(null);
    }
    //
    else
      _GetImage(
        imageProvider: _imageProvider,
        loadCallback: _loadCallback,
        buildContext: context,
      ).run();
  }

  void _loadCallback(ui.Image image) {
    if (mounted)
      setState(() {
        _toByteData(image);
      });
  }

  void _toByteData(ui.Image? image) {
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
        if (mounted) setState(() {});
      });
    }
  }

  /// Pixel coordinates: (0,0) → (width-1, height-1).
  Color pixelColorAt(int x, int y) {
    if (byteData == null ||
        width == null ||
        height == null ||
        x < 0 ||
        x >= width! ||
        y < 0 ||
        y >= height!)
      return defaultColor;
    else {
      var byteOffset = 4 * (x + (y * width!));
      return _colorAtByteOffset(byteOffset);
    }
  }

  /// Pixel coordinates: (-1, -1) → (1, 1).
  Color pixelColorAtAlignment(Alignment? alignment) {
    if (byteData == null ||
        width == null ||
        height == null ||
        alignment == null ||
        alignment.x < -1.0 ||
        alignment.x > 1.0 ||
        alignment.y < -1.0 ||
        alignment.y > 1.0) return defaultColor;

    Offset offset = alignment.alongSize(Size(width!.toDouble() - 1.0, height!.toDouble() - 1.0));
    return pixelColorAt(offset.dx.round(), offset.dy.round());
  }

  Color _colorAtByteOffset(int byteOffset) => Color(_rgbaToArgb(byteData!.getUint32(byteOffset)));

  int _rgbaToArgb(int rgbaColor) {
    int a = rgbaColor & 0xFF;
    int rgb = rgbaColor >> 8;
    return rgb + (a << 24);
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        ImgDetails(
          width: width,
          height: height,
          uiImage: image,
          byteData: byteData,
          pixelColorAt: pixelColorAt,
          pixelColorAtAlignment: pixelColorAtAlignment,
        ),
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
    required this.imageProvider,
    required this.loadCallback,
    required this.buildContext,
  });

  final ImageProvider imageProvider;

  final void Function(ui.Image) loadCallback;

  final BuildContext buildContext;

  void run() async {
    //
    ImageConfiguration imageConfiguration = createLocalImageConfiguration(buildContext);

    Object key = await imageProvider.obtainKey(imageConfiguration);

    final ImageStreamCompleter? completer = PaintingBinding.instance!.imageCache!.putIfAbsent(
      key, // key
      // ignore: invalid_use_of_protected_member
      () => imageProvider.load(key, _decoder), // loader
      onError: null,
    );

    if (completer != null) {
      //
      _ListenerManager listenerManager = _ListenerManager(loadCallback);

      ImageListener onImage = listenerManager.onImage;
      ImageErrorListener onError = listenerManager.onError;

      ImageStreamListener listener = ImageStreamListener(
        onImage,
        onError: onError,
        onChunk: null,
      );

      listenerManager.removeListener = () {
        completer.removeListener(listener);
      };

      completer.addListener(listener);
    }
  }

  Future<ui.Codec> _decoder(
    Uint8List bytes, {
    bool? allowUpscaling,
    int? cacheWidth,
    int? cacheHeight,
  }) =>
      PaintingBinding.instance!
          .instantiateImageCodec(bytes, cacheWidth: cacheWidth, cacheHeight: cacheHeight);
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// This is necessary because we want to remove the listener as soon as it's called.
class _ListenerManager {
  _ListenerManager(this.loadCallback);

  late VoidCallback removeListener;

  final void Function(ui.Image) loadCallback;

  void onImage(ImageInfo image, bool synchronousCall) {
    loadCallback(image.image);
    removeListener();
  }

  void onError(dynamic exception, StackTrace? stackTrace) {
    removeListener();
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
