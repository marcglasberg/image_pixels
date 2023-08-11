[![pub package](https://img.shields.io/pub/v/image_pixels.svg)](https://pub.dartlang.org/packages/image_pixels)

# image_pixels

This package allows you to build a widget that depends on, or uses the values of:

* The _width_ and _height_ of some image, or
* The _color_ of the image pixels

Try running
the <a href="https://github.com/marcglasberg/image_pixels/blob/master/example/lib/main.dart">
Example</a>.

## Extend the background-color of an image

The `ImagePixels.container()` constructor adds a background-color that is the same color as the
image pixel at the `colorAlignment` position.

For example, suppose you put an image inside a `Container`, like this:

```   
Container(
    width: 250,
    height: 100,                           
    alignment: Alignment.center,
    child: 
        Container(    
            width: 40.0, 
            height: 60.0, 
            child: Image(image: myImageProvider),
        ),
);
```

![](https://github.com/marcglasberg/image_pixels/blob/master/example/lib/images/with_container.jpg)

<br>

Now, if you wrap it with an `ImagePixels.container`:

```
ImagePixels.container(
    imageProvider: myImageProvider,    
    colorAlignment: Alignment.topLeft,
    child: 
        Container(
            width: 250,
            height: 100,                           
            alignment: Alignment.center,
            child: 
                Container(    
                    width: 40.0, 
                    height: 60.0, 
                    child: Image(image: myImageProvider),
                ),
        );
);
```

![](https://github.com/marcglasberg/image_pixels/blob/master/example/lib/images/with_image_pixels.jpg)

<br>

## Using a builder

The `ImagePixels` constructor lets you define an image through an `imageProvider`, and then use
a `builder` to build a child widget that depends on the image dimensions and the color of its
pixels.

The default constructor lets you provide the `imageProvider`, the `builder`, as well as
a `defaultColor` to be used when reading pixels outside the image bounds or while the image is
still downloading.

For example, this will display the size of the image as a `Text` widget:

```
ImagePixels(
    imageProvider: imageProvider,
    defaultColor: Colors.grey,
    builder: (context, img) => Text("Img size is: ${img.width} × ${img.height}"),
    );
```

<br>

### Builder parameters

The `builder` function gives you access to an `img` parameter of type `ImgDetails`, with the
following information:

* If the image is already available, `img.hasImage` is `true`, and `img.width` and `img.height`
  indicate the image dimensions.


* While the image is **not** yet available,
  `img.hasImage` is `false`, and `img.width` and `img.height` are `null`.


* The functions `img.pixelColorAt()` and `img.pixelColorAtAlignment()`
  can be used in the `builder` body to read the color of the image pixels.


* If the coordinates point to outside the image, or if the image is not yet available (is still
  being downloaded or failed to download), then these functions will return the `defaultColor`
  provided in the `ImagePixels` constructor.


* The `img.uiImage` parameter contains the image as a `ui.Image` type. It will be `null` while the
  image is still downloading.


* The `img.byteData` parameter contains the image as a `ByteData` type. It will be `null` while the
  image is still downloading.

<br>

## Other use cases

* **Getting the tapped pixel color**: By wrapping the child of the `ImagePixel` with
  a `GestureDetector` you can obtain the x/y position where the user tapped the image. From this
  information, you can then determine the color of the tapped pixel.
  Try running
  the <a href="https://github.com/marcglasberg/image_pixels/blob/master/example/lib/main_find_color.dart">
  Example</a>.


* **Modifying the image**: The child of the `ImagePixel` can be a `CustomPainter`. Then, you can
  use a **canvas** to paint whatever you want on top of the image, or else create an entirely new
  image from the pixels of the original image.

<br>

***

*The Flutter packages I've authored:*

* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/fast_immutable_collections">fast_immutable_collections</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/image_pixels">image_pixels</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a>
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a>
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>
* <a href="https://pub.dev/packages/weak_map">weak_map</a>
* <a href="https://pub.dev/packages/themed">themed</a>

*My Medium Articles:*

* <a href="https://medium.com/flutter-community/https-medium-com-marcglasberg-async-redux-33ac5e27d5f6">
  Async Redux: Flutter’s non-boilerplate version of Redux</a> (
  versions: <a href="https://medium.com/flutterando/async-redux-pt-brasil-e783ceb13c43">
  Português</a>)
* <a href="https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9">
  i18n_extension</a> (
  versions: <a href="https://medium.com/flutterando/qual-a-forma-f%C3%A1cil-de-traduzir-seu-app-flutter-para-outros-idiomas-ab5178cf0336">
  Português</a>)
* <a href="https://medium.com/flutter-community/flutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2">
  Flutter: The Advanced Layout Rule Even Beginners Must Know</a> (
  versions: <a href="https://habr.com/ru/post/500210/">русский</a>)
* <a href="https://medium.com/flutter-community/the-new-way-to-create-themes-in-your-flutter-app-7fdfc4f3df5f">
  The New Way to create Themes in your Flutter App</a> 

*My article in the official Flutter documentation*:

* <a href="https://flutter.dev/docs/development/ui/layout/constraints">Understanding constraints</a>

<br>_Marcelo Glasberg:_<br>
_https://github.com/marcglasberg_<br>
_https://twitter.com/glasbergmarcelo_<br>
_https://stackoverflow.com/users/3411681/marcg_<br>
_https://medium.com/@marcglasberg_<br>

