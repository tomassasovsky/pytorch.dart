import 'package:meta/meta.dart';

/// means for RGB channels normalization, length must equal 3, RGB order
const kTorchvisionNormMeanRgb = [0.485, 0.456, 0.406];

/// standard deviation for RGB channels normalization, length must equal 3, RGB
const kTorchvisionNormStdRgb = [0.229, 0.224, 0.225];

/// {@template pytorch_model}
/// A class that represents a PyTorch model.
/// {@endtemplate}
@protected
@immutable
class PytorchModel {
  /// {@macro pytorch_model}
  const PytorchModel(this.index);

  /// Used to identify the model in the native platform.
  final int index;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PytorchModel &&
          runtimeType == other.runtimeType &&
          index == other.index;

  @override
  int get hashCode => index.hashCode;
}
