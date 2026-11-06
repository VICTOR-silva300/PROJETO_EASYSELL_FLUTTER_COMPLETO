import 'profile_photo_storage_stub.dart'
    if (dart.library.html) 'profile_photo_storage_web.dart'
    as platform;

Future<String?> readProfilePhoto(String key) => platform.readProfilePhoto(key);

Future<bool> writeProfilePhoto(String key, String value) =>
    platform.writeProfilePhoto(key, value);

Future<void> removeProfilePhoto(String key) => platform.removeProfilePhoto(key);
