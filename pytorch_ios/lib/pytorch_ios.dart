// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pytorch_platform_interface/pytorch_platform_interface.dart';

/// The iOS implementation of [PytorchPlatform].
class PytorchIOS extends PytorchPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pytorch_ios');

  /// Registers this class as the default instance of [PytorchPlatform]
  static void registerWith() {
    PytorchPlatform.instance = PytorchIOS();
  }

  @override
  Future<PytorchModel> loadModel(String path) async {
    final absPath = await getAbsolutePath(path);
    final index = await methodChannel.invokeMethod<int>('loadModel', {
      'absPath': absPath,
      'assetPath': path,
    });

    if (index == null) {
      throw Exception('Unable to load model.');
    }

    return PytorchModel(index);
  }

  @override
  Future<List<num>?> getPrediction(
    List<double> input,
    PytorchModel model, {
    required List<int> shape,
    required DType dtype,
  }) async {
    final prediction = await methodChannel.invokeListMethod<num>('predict', {
      'index': model.index,
      'data': input,
      'shape': shape,
      'dtype': dtype.toString().split('.').last,
    });

    return prediction;
  }

  @override
  Future<String?> getImagePrediction(
    File image,
    PytorchModel model,
    int width,
    int height,
    String labelPath, {
    List<double> mean = kTorchvisionNormMeanRgb,
    List<double> std = kTorchvisionNormStdRgb,
  }) async {
    assert(mean.length == 3, 'Mean must be a list of 3 values');
    assert(std.length == 3, 'Std must be a list of 3 values');

    if (!image.existsSync()) {
      throw const StdinException('Image file does not exist');
    }

    final labels = await getLabels(labelPath);
    final byteArray = image.readAsBytesSync();
    final prediction =
        await methodChannel.invokeListMethod<num>('predictImage', {
      'index': model.index,
      'image': byteArray,
      'width': width,
      'height': height,
      'mean': mean,
      'std': std
    });

    num maxScore = double.negativeInfinity;
    var maxScoreIndex = -1;

    if (prediction == null) {
      return null;
    }

    for (var i = 0; i < prediction.length; i++) {
      if (prediction[i] > maxScore) {
        maxScore = prediction[i];
        maxScoreIndex = i;
      }
    }

    return labels[maxScoreIndex];
  }

  @override
  Future<List<num>?> getImagePredictionList(
    File image,
    PytorchModel model,
    int width,
    int height, {
    List<double> mean = kTorchvisionNormMeanRgb,
    List<double> std = kTorchvisionNormStdRgb,
  }) async {
    // Assert mean std
    assert(mean.length == 3, 'Mean should have size of 3');
    assert(std.length == 3, 'STD should have size of 3');

    if (!image.existsSync()) {
      throw const StdinException('Image file does not exist');
    }

    final prediction =
        await methodChannel.invokeListMethod<num>('predictImage', {
      'index': model.index,
      'image': image.readAsBytesSync(),
      'width': width,
      'height': height,
      'mean': mean,
      'std': std
    });

    return prediction;
  }
}
