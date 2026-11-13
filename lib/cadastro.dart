import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api_service.dart';
import 'app_shell.dart';
import 'categorias_empresa.dart';
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
  final nomeEmpresaController = TextEditingController();
  final cnpjEmpresaController = TextEditingController();
  final cpfResponsavelController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  String? categoriaEmpresaSelecionada;
  String? erroCnpj;
  String? erroCpfResponsavel;
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
    nomeEmpresaController.dispose();
    cnpjEmpresaController.dispose();
    cpfResponsavelController.dispose();
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

  Future<void> _completarContaExistente({
    required String email,
    required String senha,
    required String nomeEmpresa,
    required String categoria,
    required String cnpj,
    required String cpfResponsavel,
  }) async {
    ApiService.logout();

    try {
      await ApiService.login(email, senha, permitirEmpresaAusente: true);
    } catch (error) {
      ApiService.logout();
      final detalhe = error.toString().replaceFirst('Exception: ', '');
      final orientacao = detalhe.toLowerCase().contains('credenciais inválidas')
          ? ' Se já tentou cadastrar este e-mail, volte ao login, use '
                '"Esqueceu sua senha?" e depois tente novamente com a nova senha.'
          : ' Confira os dados ou tente novamente.';
      throw Exception(
        'Não foi possível recuperar a conta. $orientacao Detalhe: $detalhe',
      );
    }

    if (ApiService.companyId != null && ApiService.companyId!.isNotEmpty) {
      ApiService.logout();
      throw Exception(
        'Já existe uma conta completa com este e-mail. Entre pela tela de login.',
      );
    }

    final id = ApiService.userId;
    if (id == null || id.isEmpty) {
      ApiService.logout();
      throw Exception('A API não retornou o usuário para concluir o cadastro.');
    }

    try {
      await ApiService.bootstrapCompany(
        id,
        nomeEmpresa,
        categoria: categoria,
        cnpj: cnpj,
        cpfResponsavel: cpfResponsavel,
      );
      if (ApiService.companyId == null || ApiService.companyId!.isEmpty) {
        throw Exception('A API não retornou o identificador da empresa.');
      }
    } catch (error) {
      ApiService.logout();
      throw Exception(
        'A conta anterior foi encontrada, mas não foi possível concluir o '
        'cadastro da empresa: '
        '${error.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> cadastrar() async {
    FocusScope.of(context).unfocus();

    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final nomeEmpresa = nomeEmpresaController.text.trim();
    final categoria = categoriaEmpresaSelecionada;
    final cnpj = cnpjEmpresaController.text;
    final cpfResponsavel = cpfResponsavelController.text;
    final senha = senhaController.text;
    final confirmar = confirmarSenhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmar.isEmpty) {
      aviso('Preencha todos os campos.');
      return;
    }

    if (nomeEmpresa.isEmpty) {
      aviso('Informe o nome da empresa.');
      return;
    }

    if (categoria == null) {
      aviso('Selecione a categoria da empresa.');
      return;
    }

    if (cnpj.replaceAll(RegExp(r'\D'), '').length != 14) {
      setState(() => erroCnpj = 'Informe os 14 dígitos do CNPJ.');
      aviso('O CNPJ deve conter 14 dígitos.');
      return;
    }
    setState(() => erroCnpj = null);

    if (cpfResponsavel.replaceAll(RegExp(r'\D'), '').length != 11) {
      setState(() => erroCpfResponsavel = 'Informe os 11 dígitos do CPF.');
      aviso('O CPF do responsável deve conter 11 dígitos.');
      return;
    }
    setState(() => erroCpfResponsavel = null);

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      aviso('Digite um e-mail válido.');
      return;
    }

    if (senha.length < 8) {
      aviso('A senha precisa ter pelo menos 8 caracteres.');
      return;
    }

    if (senha != confirmar) {
      aviso('As senhas não coincidem.');
      return;
    }

    if (carregando) return;

    setState(() => carregando = true);

    try {
      var sessaoRecuperada = false;
      try {
        await ApiService.register(
          nome,
          email,
          senha,
          nomeEmpresa: nomeEmpresa,
          categoria: categoria,
          cnpj: cnpj,
          cpfResponsavel: cpfResponsavel,
        );
      } catch (error) {
        if (!error.toString().contains('Falha ao criar o usuário (HTTP 500)')) {
          rethrow;
        }

        await _completarContaExistente(
          email: email,
          senha: senha,
          nomeEmpresa: nomeEmpresa,
          categoria: categoria,
          cnpj: cnpj,
          cpfResponsavel: cpfResponsavel,
        );
        sessaoRecuperada = true;
      }

      if (!sessaoRecuperada) {
        try {
          await ApiService.login(email, senha);
        } catch (error) {
          throw Exception(
            'A conta e a empresa foram criadas, mas o login automático falhou. '
            'Tente entrar pela tela de login. Detalhe: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          );
        }
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      aviso(e.toString().replaceFirst('Exception: ', ''));
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
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1600),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 28,
                                      horizontal: 16,
                                    ),
                                    child: Center(
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
                                  child: SizedBox(
                                    height: constraints.maxHeight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Center(child: _ilustracao()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Center(
            child: Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 1,
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
          _tituloSecao(Icons.storefront_outlined, 'Dados da empresa'),
          const SizedBox(height: 17),
          _campo(
            'Nome da empresa',
            nomeEmpresaController,
            'Ex.: EasySell Comércio',
            Icons.storefront_outlined,
            capitalizacao: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _campoCategoriaEmpresa(),
          const SizedBox(height: 16),
          _campo(
            'CNPJ',
            cnpjEmpresaController,
            '14 dígitos, somente números',
            Icons.badge_outlined,
            tipo: TextInputType.number,
            formatadores: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 14,
            erro: erroCnpj,
            mudou: (_) {
              if (erroCnpj != null) setState(() => erroCnpj = null);
            },
          ),
          const SizedBox(height: 16),
          _campo(
            'CPF do responsável',
            cpfResponsavelController,
            '11 dígitos, somente números',
            Icons.person_pin_outlined,
            tipo: TextInputType.number,
            formatadores: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 11,
            erro: erroCpfResponsavel,
            mudou: (_) {
              if (erroCpfResponsavel != null) {
                setState(() => erroCpfResponsavel = null);
              }
            },
          ),
          const SizedBox(height: 25),
          _tituloSecao(Icons.lock_outline_rounded, 'Segurança'),
          const SizedBox(height: 17),
          _campo(
            'Senha',
            senhaController,
            'Mínimo de 8 caracteres',
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

  Widget _campoCategoriaEmpresa() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria da empresa',
          style: TextStyle(
            color: c.texto,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(
          initialValue: categoriaEmpresaSelecionada,
          isExpanded: true,
          dropdownColor: c.superficie,
          style: TextStyle(color: texto, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Selecione uma categoria',
            hintStyle: TextStyle(color: c.textoFraco, fontSize: 12),
            prefixIcon: Icon(Icons.category_outlined, color: azul, size: 19),
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
          items: categoriasEmpresa
              .map(
                (categoria) => DropdownMenuItem(
                  value: categoria,
                  child: Text(
                    categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (categoria) {
            setState(() => categoriaEmpresaSelecionada = categoria);
          },
        ),
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
    List<TextInputFormatter>? formatadores,
    int? maxLength,
    String? erro,
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
          inputFormatters: formatadores,
          maxLength: maxLength,
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
            errorText: erro,
            filled: true,
            fillColor: c.ehEscuro
                ? const Color(0xFF080D21)
                : const Color(0xFFF1F5FC),
            counterText: maxLength == null ? null : '',
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: texto,
                fontSize: 31,
                height: 1.25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
              children: [
                const TextSpan(
                  text: 'Seu próximo grande\nresultado começa com\n',
                ),
                TextSpan(
                  text: 'um novo começo.',
                  style: TextStyle(color: azul, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Container(
            width: 72,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [azul, roxo]),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Organize seu negócio e acompanhe cada conquista em um só lugar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textoSuave, fontSize: 14, height: 1.7),
          ),
          const SizedBox(height: 32),
          _rodapeSeguro(),
        ],
      ),
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
            color: const Color(0xFF35D6A0),
            size: 17,
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              'Ambiente seguro e protegido',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
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
