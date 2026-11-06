import 'package:flutter/material.dart';

import 'api_service.dart';
import 'nova_senha.dart';
import 'tema.dart';

class EsqueciSenha extends StatefulWidget {
  const EsqueciSenha({super.key});

  @override
  State<EsqueciSenha> createState() => _EsqueciSenhaState();
}

class _EsqueciSenhaState extends State<EsqueciSenha> {
  final emailController = TextEditingController();
  AppCores get c => context.cores;
  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> enviarLink() async {
    final email = emailController.text.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _aviso('Digite um e-mail válido.');
      return;
    }

    if (carregando) return;
    setState(() => carregando = true);

    try {
      await ApiService.solicitarRecuperacaoSenha(email);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NovaSenha(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _aviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: c.fundo2,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded, color: c.texto),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppCores.gradRoxo,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Recuperar senha',
                      style: TextStyle(
                        color: c.texto,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Informe o e-mail da sua conta. Enviaremos um código para você criar uma nova senha.',
                      style: TextStyle(
                        color: c.textoSuave,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'E-mail cadastrado',
                      style: TextStyle(
                        color: c.texto,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => enviarLink(),
                      style: TextStyle(color: c.texto),
                      decoration: InputDecoration(
                        hintText: 'voce@empresa.com',
                        prefixIcon: Icon(Icons.email_outlined, color: c.textoFraco),
                        filled: true,
                        fillColor: c.superficie,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: c.bordaSutil),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: c.bordaSutil),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: c.azul, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: carregando ? null : enviarLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.roxo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: carregando
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Enviar código de recuperação',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Voltar para o login',
                          style: TextStyle(color: c.textoSuave),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
