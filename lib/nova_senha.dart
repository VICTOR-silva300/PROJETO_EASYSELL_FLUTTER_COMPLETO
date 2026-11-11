import 'package:flutter/material.dart';

import 'api_service.dart';
import 'tema.dart';

class NovaSenha extends StatefulWidget {
  final String email;

  const NovaSenha({super.key, required this.email});

  @override
  State<NovaSenha> createState() => _NovaSenhaState();
}

class _NovaSenhaState extends State<NovaSenha> {
  final codigoController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarController = TextEditingController();

  AppCores get c => context.cores;
  bool mostrarSenha = false;
  bool mostrarConfirmacao = false;
  bool carregando = false;

  @override
  void dispose() {
    codigoController.dispose();
    senhaController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  void aviso(String texto, {bool erro = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? c.fundo2 : c.verde,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> salvarNovaSenha() async {
    FocusScope.of(context).unfocus();

    final codigo = codigoController.text.trim();
    final senha = senhaController.text;
    final confirmar = confirmarController.text;

    if (codigo.length != 8 || int.tryParse(codigo) == null) {
      aviso('Digite o código de 8 números recebido no e-mail.');
      return;
    }

    if (senha.length < 6) {
      aviso('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    if (senha != confirmar) {
      aviso('As senhas não coincidem.');
      return;
    }

    if (carregando) return;
    setState(() => carregando = true);

    try {
      await ApiService.redefinirSenha(
        email: widget.email,
        codigo: codigo,
        novaSenha: senha,
      );

      if (!mounted) return;
      aviso(
        'Senha alterada com sucesso! Entre com sua nova senha.',
        erro: false,
      );
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      aviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  InputDecoration decoracao(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: c.textoFraco),
      suffixIcon: suffix,
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
                    const SizedBox(height: 25),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppCores.gradRoxo,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.password_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Criar nova senha',
                      style: TextStyle(
                        color: c.texto,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Digite o código enviado para ${widget.email} e escolha uma nova senha.',
                      style: TextStyle(
                        color: c.textoSuave,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Código de recuperação',
                      style: TextStyle(
                        color: c.texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: codigoController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      style: TextStyle(
                        color: c.texto,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: decoracao(
                        '00000000',
                        Icons.verified_user_outlined,
                      ).copyWith(counterText: ''),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Nova senha',
                      style: TextStyle(
                        color: c.texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: senhaController,
                      obscureText: !mostrarSenha,
                      style: TextStyle(color: c.texto),
                      decoration: decoracao(
                        'Mínimo de 6 caracteres',
                        Icons.lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => mostrarSenha = !mostrarSenha),
                          icon: Icon(
                            mostrarSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: c.textoFraco,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Confirmar nova senha',
                      style: TextStyle(
                        color: c.texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmarController,
                      obscureText: !mostrarConfirmacao,
                      onSubmitted: (_) => salvarNovaSenha(),
                      style: TextStyle(color: c.texto),
                      decoration: decoracao(
                        'Digite a senha novamente',
                        Icons.lock_reset_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => mostrarConfirmacao = !mostrarConfirmacao,
                          ),
                          icon: Icon(
                            mostrarConfirmacao
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: c.textoFraco,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: carregando ? null : salvarNovaSenha,
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
                                'Salvar nova senha',
                                style: TextStyle(fontWeight: FontWeight.w800),
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
