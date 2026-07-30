import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// Decodes the first QR payload found in [bytes], or null if none.
String? decodeQrFromImageBytes(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  final abgr = image
      .convert(numChannels: 4)
      .getBytes(order: img.ChannelOrder.abgr)
      .buffer
      .asInt32List();
  final source = RGBLuminanceSource(image.width, image.height, abgr);
  final bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
  try {
    return QRCodeReader().decode(bitmap).text;
  } on Object {
    try {
      return QRCodeReader()
          .decode(BinaryBitmap(HybridBinarizer(source)))
          .text;
    } on Object {
      return null;
    }
  }
}
