import 'dart:html' as html;

Future<String?> readProfilePhoto(String key) async =>
    html.window.localStorage[key];

Future<bool> writeProfilePhoto(String key, String value) async {
  try {
    html.window.localStorage[key] = value;
    return html.window.localStorage[key] == value;
  } on Object catch (error) {
    throw Exception('Armazenamento local do navegador indisponível: $error');
  }
}

Future<void> removeProfilePhoto(String key) async {
  html.window.localStorage.remove(key);
}
