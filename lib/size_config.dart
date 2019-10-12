import 'package:flutter/widgets.dart';

/*
Device pixels are also referred to as physical pixels. Logical pixels are also referred to as device-independent or resolution-independent pixels.

By definition, there are roughly 38 logical pixels per centimeter, or about 96 logical pixels per inch, of the physical display. The value returned by devicePixelRatio is ultimately obtained either from the hardware itself, the device drivers, or a hard-coded value stored in the operating system or firmware, and may be inaccurate, sometimes by a significant margin.

The Flutter framework operates in logical pixels, so it is rarely necessary to directly deal with this property.

https://api.flutter.dev/flutter/dart-ui/Window/devicePixelRatio.html

 */
class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double safeAreaHorizontal;
  static double safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  static double safeAreaWidth;
  static double safeAreaHeight;

  static double factor;

  static const designScreenWidth = 375;
  static const designScreenHeight = 812;

  // TODO: sizing elements relative to pixel dencity instead of 100% of height
  // So that the header height stays the same on all devices

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    factor = _mediaQueryData.devicePixelRatio / 2;
    factor = 1;

    print('_mediaQueryData.devicePixelRatio ${_mediaQueryData.devicePixelRatio}');
    print('SizeConfig.factor $factor');

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    safeAreaWidth = screenWidth - safeAreaHorizontal;
    safeAreaHeight = screenHeight - safeAreaVertical;
  }
}
