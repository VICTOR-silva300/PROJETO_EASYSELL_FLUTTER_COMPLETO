
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cadastro.dart';
import 'esqueci_senha.dart';
import 'app_shell.dart';
import 'tema.dart';
import 'api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool mostrarSenha = false;
  bool carregando = false;

  AppCores get c => context.cores;

  Color get azul => c.azul;
  Color get azulClaro => c.roxoClaro;
  Color get azulEscuro => c.roxo;
  Color get fundoLogin => c.fundo;
  Color get painelLogin => c.fundo2;
  Color get bordaLogin => c.bordaMedia;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _mensagem('Preencha o e-mail e a senha.');
      return;
    }

    if (carregando) return;

    setState(() => carregando = true);

    try {
      await ApiService.login(email, senha);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } catch (e) {
      if (!mounted) return;
      _mensagem(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: painelLogin,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Cadastro()),
    );
  }

  void abrirEsqueciSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EsqueciSenha()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
        child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FundoLoginPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            top: -150,
            left: -150,
            child: _brilho(azul, 350),
          ),
          Positioned(
            right: -180,
            top: 240,
            child: _brilho(azulClaro, 350),
          ),
          Positioned(
            bottom: -190,
            left: -30,
            child: _brilho(azulEscuro, 370),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 490),
                  child: Column(
                    children: [
                      _cabecalho(),
                      const SizedBox(height: 42),
                      _cardLogin(),
                      const SizedBox(height: 20),
                      _seguranca(),
                      const SizedBox(height: 28),
                      _rodape(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _brilho(Color cor, double tamanho) {
    return IgnorePointer(
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cor.withAlpha(24),
              blurRadius: 125,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Column(
      children: [
        Text(
          'EASYSELL',
          style: GoogleFonts.montserrat(
            color: c.texto,
            fontSize: 43,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, azul],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'GESTÃO INTELIGENTE',
              style: GoogleFonts.montserrat(
                color: c.textoFraco,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 28,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [azul, Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardLogin() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.cardA, c.cardB, c.superficie],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: bordaLogin.withAlpha(220),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(65),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: azul.withAlpha(15),
            blurRadius: 38,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [azulClaro, azul],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: azul.withAlpha(35),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo de volta!',
                      style: GoogleFonts.roboto(
                        color: c.texto,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Entre para continuar gerenciando seu negócio.',
                      style: TextStyle(
                        color: c.textoSuave,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 27),
          _linhaDecorativa(),
          const SizedBox(height: 27),
          _label('E-mail'),
          const SizedBox(height: 9),
          _campo(
            controller: emailController,
            hint: 'Digite seu e-mail',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _label('Senha'),
          const SizedBox(height: 9),
          _campo(
            controller: senhaController,
            hint: 'Digite sua senha',
            icon: Icons.lock_outline_rounded,
            obscureText: !mostrarSenha,
            suffixIcon: IconButton(
              tooltip: mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
              onPressed: () {
                setState(() => mostrarSenha = !mostrarSenha);
              },
              icon: Icon(
                mostrarSenha
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: c.textoFraco,
                size: 19,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: abrirEsqueciSenha,
              style: TextButton.styleFrom(
                foregroundColor: azulClaro,
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  color: azulClaro,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _botaoEntrar(),
          const SizedBox(height: 14),
          _botaoCadastro(),
        ],
      ),
    );
  }

  Widget _linhaDecorativa() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: bordaLogin.withAlpha(180)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: azulClaro,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: azul.withAlpha(100),
                  blurRadius: 9,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: bordaLogin.withAlpha(180)),
        ),
      ],
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: TextStyle(
        color: c.texto,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autocorrect: false,
      style: TextStyle(
        color: c.texto,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: azulClaro,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: c.textoFraco,
          fontSize: 11,
        ),
        prefixIcon: SizedBox(
          width: 46,
          child: Icon(
            icon,
            color: azulClaro,
            size: 19,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 48,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: c.ehEscuro ? const Color(0xFF080D19) : const Color(0xFFF1F5FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: c.bordaMedia,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: azul,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _botaoEntrar() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [azulClaro, azulEscuro],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: azul.withAlpha(65),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: carregando ? null : entrar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: carregando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _botaoCadastro() {
    return SizedBox(
      width: double.infinity,
      height: 51,
      child: OutlinedButton(
        onPressed: abrirCadastro,
        style: OutlinedButton.styleFrom(
          foregroundColor: c.texto,
          side: BorderSide(
            color: bordaLogin.withAlpha(220),
            width: 1,
          ),
          backgroundColor: Colors.white.withAlpha(3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              color: c.textoSuave,
              size: 17,
            ),
            SizedBox(width: 9),
            Text(
              'Criar uma nova conta',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seguranca() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: c.ehEscuro ? const Color(0xFF071A1B) : const Color(0xFFEAFBF5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: c.ehEscuro ? const Color(0xFF12483F).withAlpha(180) : const Color(0xFF9ADBC8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: c.ehEscuro ? const Color(0xFF35D6A0) : const Color(0xFF087F5B),
            size: 17,
          ),
          SizedBox(width: 9),
          Text(
            'Ambiente seguro e protegido',
            style: TextStyle(
              color: c.textoSuave,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rodape() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: azulClaro,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'EASYSELL',
              style: TextStyle(
                color: c.textoFraco,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: azulClaro,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Sua gestão. Mais simples. Mais inteligente.',
          style: TextStyle(
            color: c.textoFraco,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}


class _FundoLoginPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Brilho azul mais intenso no canto superior esquerdo.
    paint.shader = const RadialGradient(
      colors: [
        Color(0x553D8BFF),
        Color(0x222563EB),
        Colors.transparent,
      ],
      stops: [0.0, 0.45, 1.0],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.02, size.height * 0.05),
        radius: size.width * 0.65,
      ),
    );

    canvas.drawRect(Offset.zero & size, paint);

    // Brilho azul mais forte na lateral direita.
    paint.shader = const RadialGradient(
      colors: [
        Color(0x443D8BFF),
        Color(0x182563EB),
        Colors.transparent,
      ],
      stops: [0.0, 0.45, 1.0],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width, size.height * 0.8),
        radius: size.width * 0.45,
      ),
    );

    canvas.drawRect(Offset.zero & size, paint);

    // Linhas decorativas azuis nas extremidades.
    final linha = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = LinearGradient(
        colors: [
          Color(0x003D8BFF),
          Color(0xCC2563EB),
          Color(0xAA60A5FA),
          Color(0x003D8BFF),
        ],
      ).createShader(Offset.zero & size);

    final caminho = Path()
      ..moveTo(-20, size.height * 0.16)
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.10,
        size.width * 0.06,
        -size.height * 0.06,
        size.width * 0.20,
        -20,
      );

    canvas.drawPath(caminho, linha);

    final caminho2 = Path()
      ..moveTo(size.width * 0.78, size.height + 20)
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.75,
        size.width * 0.95,
        size.height * 0.95,
        size.width + 20,
        size.height * 0.70,
      );

    canvas.drawPath(caminho2, linha);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
