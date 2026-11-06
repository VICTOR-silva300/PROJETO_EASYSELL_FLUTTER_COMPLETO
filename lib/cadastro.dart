import 'package:flutter/material.dart';

import 'api_service.dart';
import 'app_shell.dart';
import 'tema.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  AppCores get c => context.cores;
  Color get fundo => c.fundo;
  Color get painel => c.superficie;
  Color get roxo => c.roxo;
  Color get azul => c.azul;
  Color get texto => c.texto;
  Color get textoSuave => c.textoSuave;
  Color get borda => c.bordaSutil;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool mostrarSenha = false;
  bool mostrarConfirmarSenha = false;
  bool carregando = false;

  int get forcaSenha {
    final s = senhaController.text;
    if (s.isEmpty) return 0;

    int pontos = 0;

    if (s.length >= 6) pontos++;
    if (s.length >= 10) pontos++;

    if (RegExp(r'[A-Z]').hasMatch(s) && RegExp(r'[a-z]').hasMatch(s)) {
      pontos++;
    }

    if (RegExp(r'[0-9]').hasMatch(s) && RegExp(r'[^A-Za-z0-9]').hasMatch(s)) {
      pontos++;
    }

    return pontos == 0 ? 1 : pontos;
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  void aviso(String mensagem, {bool erro = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro
            ? const Color(0xFF172B4D)
            : const Color(0xFF137A59),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> cadastrar() async {
    FocusScope.of(context).unfocus();

    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text;
    final confirmar = confirmarSenhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmar.isEmpty) {
      aviso('Preencha todos os campos.');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      aviso('Digite um e-mail válido.');
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
    var contaCriada = false;

    try {
      await ApiService.register(nome, email, senha);
      contaCriada = true;
      await ApiService.login(email, senha);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final erro = e.toString().replaceFirst('Exception: ', '');
      final erroAmigavel = erro.toLowerCase().contains('internal server error')
          ? 'O servidor da EasySell apresentou um erro interno (500) e não '
                'confirmou o cadastro. Tente novamente mais tarde ou peça ao '
                'suporte para verificar os logs da API.'
          : erro;
      aviso(
        contaCriada
            ? 'A conta foi criada, mas o login automático falhou: '
                  '$erroAmigavel. '
                  'Volte ao login e entre com seu e-mail e senha.'
            : erroAmigavel,
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  void voltarLogin() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
        child: Stack(
          children: [
            const Positioned.fill(child: _FundoNeon()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 1100;

                  if (desktop) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1600),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  40,
                                  35,
                                  20,
                                  35,
                                ),
                                child: _apresentacao(),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                    horizontal: 16,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 490,
                                    ),
                                    child: _formulario(),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: _ilustracao(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 490),
                        child: Column(
                          children: [
                            _logo(),
                            const SizedBox(height: 28),
                            _formulario(),
                            const SizedBox(height: 24),
                            _rodapeSeguro(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [azul, roxo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(color: roxo.withValues(alpha: 0.3), blurRadius: 20),
            ],
          ),
          child: const Center(
            child: Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EASYSELL',
              style: TextStyle(
                color: texto,
                fontSize: 24,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'GESTÃO INTELIGENTE',
              style: TextStyle(
                color: textoSuave,
                fontSize: 8,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _apresentacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _logo(),
        const SizedBox(height: 55),
        Text(
          'Seu negócio',
          style: TextStyle(
            color: texto,
            fontSize: 39,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'mais forte.',
          style: TextStyle(
            fontSize: 43,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: azul,
          ),
        ),
        Container(
          width: 105,
          height: 4,
          margin: const EdgeInsets.only(top: 10, bottom: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [azul, roxo]),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Text(
          'Controle suas vendas, produtos,\n'
          'funcionários e muito mais em\n'
          'um só lugar.',
          style: TextStyle(color: textoSuave, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 35),
        _beneficio(
          Icons.bar_chart_rounded,
          'Relatórios completos',
          'Tenha o controle do seu crescimento',
        ),
        const SizedBox(height: 23),
        _beneficio(
          Icons.shield_outlined,
          'Segurança dos dados',
          'Suas informações protegidas',
        ),
        const SizedBox(height: 23),
        _beneficio(
          Icons.bolt_rounded,
          'Mais produtividade',
          'Tudo o que você precisa em um só app',
        ),
        const SizedBox(height: 35),
        Text(
          'Juntos no seu\ncrescimento!',
          style: TextStyle(
            color: azul,
            fontSize: 24,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _beneficio(IconData icon, String titulo, String descricao) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                roxo.withValues(alpha: 0.3),
                azul.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borda),
          ),
          child: Icon(icon, color: azul),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: texto,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                descricao,
                style: TextStyle(color: textoSuave, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formulario() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.cardA, c.cardB, c.superficie],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: c.azul.withValues(alpha: c.ehEscuro ? 0.55 : 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: roxo.withValues(alpha: 0.16),
            blurRadius: 35,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: azul.withValues(alpha: 0.07),
            blurRadius: 55,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [azul, roxo]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crie sua conta',
                      style: TextStyle(
                        color: texto,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Comece uma nova etapa do seu negócio.',
                      style: TextStyle(color: textoSuave, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _progresso(),
          const SizedBox(height: 27),
          _tituloSecao(Icons.person_outline_rounded, 'Seus dados'),
          const SizedBox(height: 17),
          _campo(
            'Nome completo',
            nomeController,
            'Ex.: João Silva',
            Icons.person_outline_rounded,
            capitalizacao: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _campo(
            'E-mail',
            emailController,
            'exemplo@seuemail.com',
            Icons.mail_outline_rounded,
            tipo: TextInputType.emailAddress,
          ),
          const SizedBox(height: 25),
          _tituloSecao(Icons.lock_outline_rounded, 'Segurança'),
          const SizedBox(height: 17),
          _campo(
            'Senha',
            senhaController,
            'Crie uma senha forte',
            Icons.lock_outline_rounded,
            obscure: !mostrarSenha,
            mudou: (_) => setState(() {}),
            sufixo: _olho(
              mostrarSenha,
              () => setState(() => mostrarSenha = !mostrarSenha),
            ),
          ),
          const SizedBox(height: 11),
          _forcaSenhaWidget(),
          const SizedBox(height: 18),
          _campo(
            'Confirmar senha',
            confirmarSenhaController,
            'Digite a senha novamente',
            Icons.lock_outline_rounded,
            obscure: !mostrarConfirmarSenha,
            mudou: (_) => setState(() {}),
            sufixo: _olho(
              mostrarConfirmarSenha,
              () => setState(
                () => mostrarConfirmarSenha = !mostrarConfirmarSenha,
              ),
            ),
          ),
          if (confirmarSenhaController.text.isNotEmpty) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                Icon(
                  senhaController.text == confirmarSenhaController.text
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 15,
                  color: senhaController.text == confirmarSenhaController.text
                      ? const Color(0xFF35D6A0)
                      : const Color(0xFFFFB454),
                ),
                const SizedBox(width: 6),
                Text(
                  senhaController.text == confirmarSenhaController.text
                      ? 'As senhas coincidem'
                      : 'As senhas não coincidem',
                  style: TextStyle(
                    fontSize: 11,
                    color: senhaController.text == confirmarSenhaController.text
                        ? const Color(0xFF35D6A0)
                        : const Color(0xFFFFB454),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 25),
          _botaoCadastrar(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: borda)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'JÁ TEM UMA CONTA?',
                  style: TextStyle(
                    color: textoSuave.withValues(alpha: 0.8),
                    fontSize: 9,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: Divider(color: borda)),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: voltarLogin,
            style: TextButton.styleFrom(foregroundColor: azul),
            child: Text.rich(
              TextSpan(
                text: 'Voltar para o ',
                style: TextStyle(color: textoSuave, fontSize: 13),
                children: [
                  TextSpan(
                    text: 'login',
                    style: TextStyle(color: azul, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progresso() {
    return Row(
      children: [
        Expanded(
          child: _Etapa(numero: '01', titulo: 'Seus dados', ativa: true),
        ),
        Container(
          width: 32,
          height: 1,
          color: borda,
          margin: const EdgeInsets.symmetric(horizontal: 9),
        ),
        Expanded(
          child: _Etapa(numero: '02', titulo: 'Segurança', ativa: true),
        ),
      ],
    );
  }

  Widget _tituloSecao(IconData icon, String titulo) {
    return Row(
      children: [
        Icon(icon, color: azul, size: 19),
        const SizedBox(width: 9),
        Text(
          titulo,
          style: TextStyle(
            color: texto,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: borda)),
      ],
    );
  }

  Widget _campo(
    String rotulo,
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType tipo = TextInputType.text,
    TextCapitalization capitalizacao = TextCapitalization.none,
    bool obscure = false,
    Widget? sufixo,
    ValueChanged<String>? mudou,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: TextStyle(
            color: c.texto,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: tipo,
          textCapitalization: capitalizacao,
          autocorrect: false,
          onChanged: mudou,
          style: TextStyle(color: texto, fontSize: 13),
          cursorColor: azul,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textoFraco, fontSize: 12),
            prefixIcon: Icon(icon, color: azul, size: 19),
            suffixIcon: sufixo,
            filled: true,
            fillColor: c.ehEscuro
                ? const Color(0xFF080D21)
                : const Color(0xFFF1F5FC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: c.bordaMedia),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _olho(bool visivel, VoidCallback onTap) {
    return IconButton(
      tooltip: visivel ? 'Ocultar senha' : 'Mostrar senha',
      onPressed: onTap,
      icon: Icon(
        visivel ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: azul,
        size: 19,
      ),
    );
  }

  Widget _forcaSenhaWidget() {
    if (senhaController.text.isEmpty) {
      return Text(
        'Use uma combinação de letras, números e símbolos.',
        style: TextStyle(color: textoSuave, fontSize: 10),
      );
    }

    final cores = [
      const Color(0xFFFF5E77),
      const Color(0xFFFFB454),
      const Color(0xFF60A5FA),
      const Color(0xFF35D6A0),
    ];

    final labels = ['Fraca', 'Razoável', 'Boa', 'Forte'];
    final cor = cores[forcaSenha - 1];

    return Column(
      children: [
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                decoration: BoxDecoration(
                  color: i < forcaSenha ? cor : const Color(0xFF222A4A),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Icon(Icons.security_rounded, size: 13, color: cor),
            const SizedBox(width: 5),
            Text(
              'Força da senha: ${labels[forcaSenha - 1]}',
              style: TextStyle(
                color: cor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _botaoCadastrar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF60A5FA), Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: azul.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: carregando ? null : cadastrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
                    'Criar minha conta',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
      ),
    );
  }

  Widget _ilustracao() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      roxo.withValues(alpha: 0.24),
                      azul.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Transform.rotate(
                angle: -0.09,
                child: Container(
                  width: 260,
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xDD172452), Color(0xCC0C1330)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFF2563EB)),
                    boxShadow: [
                      BoxShadow(
                        color: azul.withValues(alpha: 0.15),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_graph_rounded,
                            color: Color(0xFF60A5FA),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Seu crescimento',
                            style: TextStyle(
                              color: texto,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 105,
                        child: CustomPaint(
                          painter: _GraficoPainter(),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: Color(0xFF35D6A0),
                            size: 17,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Evolua com inteligência',
                            style: TextStyle(color: textoSuave, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 15,
                child: _miniCard(Icons.bolt_rounded, azul),
              ),
              Positioned(
                bottom: 8,
                left: 12,
                child: _miniCard(Icons.inventory_2_outlined, roxo),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text(
          'Grandes resultados\ncomeçam com um novo começo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: azul,
            fontSize: 19,
            height: 1.5,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 25),
        _rodapeSeguro(),
      ],
    );
  }

  Widget _miniCard(IconData icon, Color cor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cor.withValues(alpha: 0.45), const Color(0xFF111936)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: cor.withValues(alpha: 0.15), blurRadius: 18),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 23),
    );
  }

  Widget _rodapeSeguro() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1927),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF1B574B).withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF35D6A0),
            size: 17,
          ),
          SizedBox(width: 9),
          Flexible(
            child: Text(
              'Ambiente seguro e protegido',
              style: TextStyle(
                color: textoSuave,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Etapa extends StatelessWidget {
  final String numero;
  final String titulo;
  final bool ativa;

  const _Etapa({
    required this.numero,
    required this.titulo,
    required this.ativa,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            gradient: ativa ? LinearGradient(colors: [c.azul, c.roxo]) : null,
            color: ativa ? null : c.superficie,
            shape: BoxShape.circle,
            border: Border.all(color: ativa ? c.roxo : c.bordaSutil),
          ),
          child: Center(
            child: Text(
              numero,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            titulo,
            style: TextStyle(
              color: c.textoSuave,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FundoNeon extends StatelessWidget {
  const _FundoNeon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FundoPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _FundoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.shader =
        const RadialGradient(
          colors: [Color(0x332563EB), Colors.transparent],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.02, size.height * 0.05),
            radius: size.width * 0.65,
          ),
        );

    canvas.drawRect(Offset.zero & size, paint);

    paint.shader =
        const RadialGradient(
          colors: [Color(0x22103DFF), Colors.transparent],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width, size.height * 0.8),
            radius: size.width * 0.45,
          ),
        );

    canvas.drawRect(Offset.zero & size, paint);

    final linha = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        colors: [
          Color(0x0060A5FA),
          Color(0xAA2563EB),
          Color(0x8860A5FA),
          Color(0x0060A5FA),
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

class _GraficoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grade = Paint()
      ..color = const Color(0xFF35416D).withValues(alpha: 0.45)
      ..strokeWidth = 0.7;

    for (int i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grade);
    }

    final pontos = [
      Offset(0, size.height * 0.83),
      Offset(size.width * 0.18, size.height * 0.66),
      Offset(size.width * 0.35, size.height * 0.73),
      Offset(size.width * 0.52, size.height * 0.38),
      Offset(size.width * 0.68, size.height * 0.46),
      Offset(size.width * 0.84, size.height * 0.18),
      Offset(size.width, size.height * 0.08),
    ];

    final caminho = Path()..moveTo(pontos.first.dx, pontos.first.dy);

    for (int i = 1; i < pontos.length; i++) {
      caminho.lineTo(pontos[i].dx, pontos[i].dy);
    }

    final area = Path.from(caminho)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final preenchimento = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x553F6BFF), Color(0x001E38A0)],
      ).createShader(Offset.zero & size);

    canvas.drawPath(area, preenchimento);

    final linha = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
      ).createShader(Offset.zero & size);

    canvas.drawPath(caminho, linha);

    final ponta = pontos.last;

    canvas.drawCircle(ponta, 5, Paint()..color = const Color(0xFF60A5FA));

    canvas.drawCircle(
      ponta,
      9,
      Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
