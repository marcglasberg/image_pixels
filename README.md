# image_pixels

**Lets you build a widget that depends on the _width_ and _height_ of some image, 
and the _color of its pixels_**.

<br>

In more detail, the `ImagePixels` widget lets you define an image through an `imageProvider`,
and then use a `builder` to build a child widget that depends on the image dimension
and the color of its pixels.

The default constructor lets you provide the `imageProvider`, the `builder`, and a
`defaultColor` to be used when reading pixels outside of the image 
(or while the image is downloading).

For example, this will print the size of the image:

```dart
ImagePixels(
    imageProvider: imageProvider,
    defaultColor: Colors.grey,
    builder: ({
          bool hasImage,
          int width,
          int height,
          ui.Image image,
          ByteData byteData,
          Color Function(int x, int y) pixelColorAt,
          Color Function(Alignment alignment) pixelColorAtAlignment,
        }) =>
            Text("The image size is: $width x $height"),
      );
```

## Builder details

The `builder` parameter is of type `BuilderFromImage`, with the following parameters: 

* If the image is already available, `hasImage` is true, 
and `width` and `height` indicate the image dimensions.

* While the image is **not** yet available, 
`hasImage` is false, and `width` and `height` are `null`.

* The `defaultColor` will be used when reading pixels outside of the image, 
or while the image is downloading.

* The functions `pixelColorAt` and `pixelColorAtAlignment` 
can be used by the `builder` to read the color of the image pixels. 

* If the coordinates point to outside of the image, 
or if the image is not yet available, then these functions will return the
default-color provided in the `ImagePixels` constructor.

* The `image` parameter contains the image as a `ui.Image` type. 
It will be null while the image is still downloading.

* The `byteData` parameter contains the image already converted into a `ByteDate` type. 
It will be null while the image is still downloading.


## Extend the image background-color  
 
The `ImagePixels.container` constructor creates a container with a background-color
that is the same color as the image pixel at the `colorAlignment` position.

For example, suppose you have some image with a solid color background. 
You want to put this image inside of a container of 100 by 100 pixels, 
but you want the image itself to have only 60 by 60 pixels. 
You want the container to have the **same** background-color as the image: 

```dart
ImagePixels.container(
    imageProvider: imageProvider,    
    colorAlignment: Alignment.topLeft,
    defaultColor: Colors.grey,
    child: Container(
               padding: const EdgeInsets.all(20.0),
               width: 60.0, 
               height: 60.0, 
               child: myImage,
               ),
  );
}
```
