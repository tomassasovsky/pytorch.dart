// Copyright (c) 2022, Sports Visio, Inc.
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:scidart/numdart.dart';

/// Return a sharpened version of the image, using an unsharp mask.
Future<Uint8List> unsharpMask({
  required String imagePath,
  CVPathFrom pathFrom = CVPathFrom.ASSETS,
  List<double> kernelSize = const [5, 5],
  double sigma = 1.0,
  double amount = 1.0,
  double threshold = 0.0,
}) async {
  final byteData = await rootBundle.load(imagePath);
  final image = byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );

  final blurred = await Cv2.gaussianBlur(
    pathString: imagePath,
    pathFrom: pathFrom,
    kernelSize: kernelSize,
    sigmaX: sigma,
  );

  if (blurred == null) {
    throw Exception('blurred is null');
  }

  final sharpened = Uint8List(image.length);
  for (var i = 0; i < image.length; i++) {
    final value = (amount + 1) * image[i] - amount * blurred[i];
    sharpened[i] = value.clamp(0, 255).round();
  }

  if (threshold > 0) {
    final imageArray = Array2d(image.cast());
    final blurredArray = Array2d(blurred.cast());
    final diff = imageArray - blurredArray;
    final list = diff.reduce(
      (previousValue, element) => previousValue + element,
    );

    final lowContrastMask =
        list.map((element) => element.abs() < threshold).toList();

    image.asMap().entries.forEach((entry) {
      if (lowContrastMask[entry.key]) {
        sharpened[entry.key] = entry.value;
      }
    });
  }

  return sharpened;
}
