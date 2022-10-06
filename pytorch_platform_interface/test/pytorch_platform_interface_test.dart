// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pytorch_platform_interface/pytorch_platform_interface.dart';

class PytorchMock extends PytorchPlatform {
  @override
  Future<PytorchModel> loadModel(String path) async => const PytorchModel(0);

  @override
  Future<List<num>?> getPrediction(
    List<double> input,
    PytorchModel model, {
    required List<int> shape,
    required DType dtype,
  }) async =>
      <num>[1, 2, 3];

  @override
  Future<String?> getImagePrediction(
    File image,
    PytorchModel model,
    int width,
    int height,
    String labelPath, {
    List<double> mean = kTorchvisionNormMeanRgb,
    List<double> std = kTorchvisionNormStdRgb,
  }) =>
      Future.value('test');

  @override
  Future<List<num>?> getImagePredictionList(
    File image,
    PytorchModel model,
    int width,
    int height, {
    List<double> mean = kTorchvisionNormMeanRgb,
    List<double> std = kTorchvisionNormStdRgb,
  }) =>
      Future.value(<num>[1, 2, 3]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PytorchPlatformInterface', () {
    late PytorchPlatform pytorchPlatform;

    setUp(() {
      pytorchPlatform = PytorchMock();
      PytorchPlatform.instance = pytorchPlatform;
    });

    group('loadModel', () {
      test('returns a PytorchModel with index 0', () async {
        final model = await PytorchPlatform.instance.loadModel('');

        expect(
          model,
          equals(const PytorchModel(0)),
        );
      });
    });
  });
}
