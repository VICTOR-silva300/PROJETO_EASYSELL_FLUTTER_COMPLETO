import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'profile_photo_storage.dart';

const _blueAvatar = LinearGradient(
  colors: [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
);

class ProfilePhoto {
  ProfilePhoto._();

  static const _keyPrefix = 'easysell_profile_photo_';
  static final image = ValueNotifier<Uint8List?>(null);
  static String get _storageKey {
    final account =
        ApiService.userId ??
        ApiService.usuario?['email']?.toString() ??
        'default';
    return '$_keyPrefix${Uri.encodeComponent(account.toLowerCase())}';
  }

  static Future<void> load() async {
    image.value = null;
    final encoded = await readProfilePhoto(_storageKey);
    if (encoded == null || encoded.isEmpty) return;

    try {
      image.value = base64Decode(encoded);
    } on FormatException {
      await removeProfilePhoto(_storageKey);
    }
  }

  static Future<void> save(Uint8List bytes) async {
    final saved = await writeProfilePhoto(_storageKey, base64Encode(bytes));
    if (!saved) {
      throw Exception('Não foi possível salvar a foto neste dispositivo.');
    }
    image.value = bytes;
  }

  static Future<void> remove() async {
    await removeProfilePhoto(_storageKey);
    image.value = null;
  }
}

class FotoPerfil extends StatelessWidget {
  const FotoPerfil({
    super.key,
    required this.tamanho,
    required this.fallback,
    this.raio,
    this.tamanhoFonte = 16,
  });

  final double tamanho;
  final String fallback;
  final double? raio;
  final double tamanhoFonte;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(raio ?? tamanho / 2);

    return ValueListenableBuilder<Uint8List?>(
      valueListenable: ProfilePhoto.image,
      builder: (context, bytes, _) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: bytes == null
              ? Container(
                  width: tamanho,
                  height: tamanho,
                  decoration: const BoxDecoration(gradient: _blueAvatar),
                  alignment: Alignment.center,
                  child: Text(
                    fallback,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: tamanhoFonte,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              : Image.memory(
                  bytes,
                  width: tamanho,
                  height: tamanho,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: tamanho,
                    height: tamanho,
                    decoration: const BoxDecoration(gradient: _blueAvatar),
                    alignment: Alignment.center,
                    child: Text(
                      fallback,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tamanhoFonte,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
