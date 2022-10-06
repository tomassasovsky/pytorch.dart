// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pytorch_platform_interface/pytorch_platform_interface.dart';

export 'src/dtype.dart';
export 'src/model.dart';

/// The interface that implementations of pytorch must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `Pytorch`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [PytorchPlatform] methods.
abstract class PytorchPlatform extends PlatformInterface {
  /// Constructs a PytorchPlatform.
  PytorchPlatform() : super(token: _token);

  static final Object _token = Object();

  static late PytorchPlatform _instance;

  /// The default instance of [PytorchPlatform] to use.
  ///
  /// By default, it is uninitialized, and will throw an [AssertionError] if
  /// accessed. Platforms should set this with their own platform-specific
  /// class that extends [PytorchPlatform] when they register themselves.
  static PytorchPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PytorchPlatform] when they register themselves.
  static set instance(PytorchPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Loads a PyTorch model from the specified path, and returns
  /// a [PytorchModel] object.
  Future<PytorchModel> loadModel(String path);

  /// Returns the path to the specified asset.
  @protected
  Future<String> getAbsolutePath(String path) async {
    final dir = await getApplicationDocumentsDirectory();
    final dirPath = join(dir.path, path);
    final data = await rootBundle.load(path);

    //copy asset to documents directory
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    //create non existant directories
    final split = path.split('/');
    var nextDir = '';
    for (var i = 0; i < split.length; i++) {
      if (i != split.length - 1) {
        nextDir += split[i];
        await Directory(join(dir.path, nextDir)).create();
        nextDir += '/';
      }
    }

    await File(dirPath).writeAsBytes(bytes);
    return dirPath;
  }

  /// Returns a prediction based on an input tensor and a model.
  Future<List<num>?> getPrediction(
    List<double> input,
    PytorchModel model, {
    required List<int> shape,
    required DType dtype,
  });

  /// Returns a prediction (label) based on an input tensor and a model.
  Future<String?> getImagePrediction(
    File image,
    PytorchModel model,
    int width,
    int height,
    String labelPath, {
    List<double> mean = kTorchvisionNormMeanRgb,
    List<double> std = kTorchvisionNormStdRgb,
  });

  /// Returns a raw prediction (label) based on
  /// an input tensor (Image file) and a model.
  Future<List<num>?> getImagePredictionList(
    File image,
    PytorchModel model,
    int width,
    int height, {
    List<double> mean = kTorchvisionNormMeanRgb,
    List<double> std = kTorchvisionNormStdRgb,
  });

  /// get labels in csv format
  @protected
  Future<List<String>> getLabels(String labelPath) async {
    final labelsData = await rootBundle.loadString(labelPath);

    if (labelPath.contains('.txt')) {
      return labelsData.split('\n');
    }

    return labelsData.split(',');
  }
}
