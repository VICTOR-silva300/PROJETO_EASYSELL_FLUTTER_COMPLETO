import 'dart:typed_data';

import 'profile_photo_picker_stub.dart'
    if (dart.library.html) 'profile_photo_picker_web.dart'
    as platform;

Future<Uint8List?> pickProfilePhoto() => platform.pickProfilePhoto();
