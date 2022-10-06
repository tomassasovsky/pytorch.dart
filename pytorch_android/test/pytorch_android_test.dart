// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pytorch_android/pytorch_android.dart';
import 'package:pytorch_platform_interface/pytorch_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PytorchAndroid', () {
    const kPlatformName = 'Android';
    late PytorchAndroid pytorch;
    late List<MethodCall> log;

    setUp(() async {
      pytorch = PytorchAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(pytorch.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      PytorchAndroid.registerWith();
      expect(PytorchPlatform.instance, isA<PytorchAndroid>());
    });

    test('loadModel returns correct name', () async {
      final name = await pytorch.loadModel('');
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
