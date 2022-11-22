// Copyright (c) 2022, Sports Visio, Inc.
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/services.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:scidart/numdart.dart';

/// Reads an image from a movie or image file
///
/// Required argument:
/// inputFile -- string, name of file. Must be a full url path, not relative.
///
/// Optional argument:
/// frame -- int, frame number to read (default None, reads first frame)
///
/// Returns image array converted to RGB, 0 to 255
Future<Uint8List> getImageFrame({
  int frame = 1,
  String? inputFile,
  String? outputPath,
}) async {
  final i = frame;
  final file = File('${outputPath ?? Directory.systemTemp.path}/frame$i.jpg');
  if (file.existsSync()) {
    file.deleteSync();
  }

  final result = await FFmpegKit.execute(
    '-accurate_seek -ss `echo $i*60.0 | bc` -i $inputFile '
    '-frames:v 1 frame$i.jpg',
  );

  final returnCode = await result.getReturnCode();
  if (returnCode?.isValueSuccess() ?? false) {
    final image = await Cv2.cvtColor(
      pathString: file.path,
      pathFrom: CVPathFrom.URL,
      outputType: Cv2.COLOR_BGR2RGB,
    );

    if (image != null) {
      return image;
    }

    throw PlatformException(
      code: 'getImageFrame',
      message: 'Failed to read image frame',
    );
  }

  throw PlatformException(
    code: returnCode.toString(),
    message: 'Failed to get frame $i',
    stacktrace: await result.getFailStackTrace(),
  );
}

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
