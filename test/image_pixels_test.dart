import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_pixels/image_pixels.dart';

void main() {
  test(
      'both constructors preserve the default grey without a Material dependency',
      () {
    final plain = ImagePixels(
        imageProvider: null, builder: (_, image) => const SizedBox());
    final container = ImagePixels.container(imageProvider: null);
    expect(plain.defaultColor.toARGB32(), 0xFF9E9E9E);
    expect(container.defaultColor, plain.defaultColor);
    expect(ImgDetails().hasImage, isFalse);
  });
}
