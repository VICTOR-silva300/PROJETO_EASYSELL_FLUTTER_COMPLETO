import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickProfilePhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 80,
  );
  return file?.readAsBytes();
}
