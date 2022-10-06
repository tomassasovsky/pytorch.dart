// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pytorch/pytorch.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PytorchModel? _customModel;

  String? _imagePrediction;
  List<num>? _prediction;
  File? _image;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // load your model
  Future<void> _loadModel() async {
    const pathCustomModel = 'assets/models/model_classification.pt';
    try {
      _customModel = await PytorchPlatform.instance.loadModel(pathCustomModel);
    } on PlatformException {
      debugPrint(
        'Failed to load model--The supported platforms are Android and iOS',
      );
    }
  }

  // run an image model
  Future<void> runImageModel() async {
    //pick a random image
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 224,
      maxWidth: 224,
    );

    if (image == null) return;

    final customModel = _customModel;
    if (customModel == null) return;

    // get prediction
    // labels are 1000 random english words for show purposes
    _imagePrediction = await PytorchPlatform.instance.getImagePrediction(
      File(image.path),
      customModel,
      224,
      224,
      'assets/labels/label_classification.txt',
    );

    setState(() {
      _image = File(image.path);
    });
  }

  // run a custom model with number inputs
  Future<void> runCustomModel() async {
    final customModel = _customModel;
    if (customModel == null) return;

    _prediction = await PytorchPlatform.instance.getPrediction(
      [1, 2, 3, 4],
      customModel,
      shape: [1, 2, 2],
      dtype: DType.float32,
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pytorch Mobile Example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image == null)
              const Text('No image selected.')
            else
              Image.file(_image!),
            Center(
              child: Visibility(
                visible: _imagePrediction != null,
                child: Text('$_imagePrediction'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: runImageModel,
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: runCustomModel,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Run custom model',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            if ((_prediction?.length ?? 0) > 0)
              Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _prediction?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Text('${_prediction?[index]}');
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
