import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

Future<Uint8List?> pickProfilePhoto() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;
  final selection = Completer<html.FileUploadInputElement>();
  final changeListener = input.onChange.listen((_) {
    if (!selection.isCompleted) selection.complete(input);
  });
  final focusListener = html.window.onFocus.listen((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!selection.isCompleted) selection.complete(input);
  });
  html.document.body?.append(input);

  try {
    input.click();
    await selection.future;
    final files = input.files;
    if (files == null || files.isEmpty) return null;

    final file = files.first;
    if (file.type.isNotEmpty && !file.type.startsWith('image/')) {
      throw Exception('Selecione um arquivo de imagem.');
    }
    if (file.size > 10 * 1024 * 1024) {
      throw Exception('A imagem deve ter no máximo 10 MB.');
    }

    final objectUrl = html.Url.createObjectUrlFromBlob(file);
    try {
      final source = html.ImageElement();
      final loaded = source.onLoad.first;
      final failed = source.onError.first.then<void>((_) {
        throw Exception('O arquivo selecionado não é uma imagem válida.');
      });
      source.src = objectUrl;
      await Future.any<void>([loaded, failed]);

      final maxSide = source.naturalWidth > source.naturalHeight
          ? source.naturalWidth
          : source.naturalHeight;
      if (maxSide == 0) {
        throw Exception('O arquivo selecionado não é uma imagem válida.');
      }
      final scale = 512 / maxSide;
      final width = (source.naturalWidth * scale).round().clamp(1, 512).toInt();
      final height = (source.naturalHeight * scale)
          .round()
          .clamp(1, 512)
          .toInt();
      final canvas = html.CanvasElement(width: width, height: height);
      canvas.context2D
        ..fillStyle = '#ffffff'
        ..fillRect(0, 0, width, height)
        ..drawImageScaled(source, 0, 0, width, height);
      final dataUrl = canvas.toDataUrl('image/jpeg', 0.82);
      return base64Decode(dataUrl.split(',').last);
    } finally {
      html.Url.revokeObjectUrl(objectUrl);
    }
  } finally {
    await changeListener.cancel();
    await focusListener.cancel();
    input.remove();
  }
}
