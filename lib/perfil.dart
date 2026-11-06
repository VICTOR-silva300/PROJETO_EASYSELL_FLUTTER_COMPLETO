import 'package:flutter/material.dart';

import 'api_service.dart';
import 'profile_photo.dart';
import 'profile_photo_picker.dart';
import 'tema.dart';

class Perfil extends StatefulWidget {
  final VoidCallback? aoVoltar;

  const Perfil({super.key, this.aoVoltar});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  AppCores get c => context.cores;

  String _nomeSalvo = 'Administrador';
  String _emailSalvo = 'admin@email.com';
  String _telefoneSalvo = '(11) 99999-9999';
  String _cargoSalvo = 'Administrador';
  String _empresaSalva = 'EasySell';

  late final TextEditingController nomeController;
  late final TextEditingController emailController;
  late final TextEditingController telefoneController;
  late final TextEditingController cargoController;
  late final TextEditingController empresaController;

  String? erroNome;
  String? erroEmail;

  bool _salvando = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();

    final usuario = ApiService.usuario;

    final nomeApi = usuario?['name']?.toString().trim();
    final emailApi = usuario?['email']?.toString().trim();
    final telefoneApi = usuario?['telefone']?.toString().trim();
    final cargoApi = usuario?['cargo']?.toString().trim();

    if (nomeApi != null && nomeApi.isNotEmpty) {
      _nomeSalvo = nomeApi;
    }

    if (emailApi != null && emailApi.isNotEmpty) {
      _emailSalvo = emailApi;
    }
    if (telefoneApi != null) _telefoneSalvo = telefoneApi;
    if (cargoApi != null) _cargoSalvo = cargoApi;

    nomeController = TextEditingController(text: _nomeSalvo);
    emailController = TextEditingController(text: _emailSalvo);
    telefoneController = TextEditingController(text: _telefoneSalvo);
    cargoController = TextEditingController(text: _cargoSalvo);
    empresaController = TextEditingController(text: _empresaSalva);

    for (final controller in [
      nomeController,
      emailController,
      telefoneController,
      cargoController,
      empresaController,
    ]) {
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }

    _carregarPerfil();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    cargoController.dispose();
    empresaController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    try {
      final usuario = await ApiService.me();

      final nome = usuario['name']?.toString().trim();
      final email = usuario['email']?.toString().trim();
      final telefone = usuario['telefone']?.toString().trim();
      final cargo = usuario['cargo']?.toString().trim();

      if (nome != null && nome.isNotEmpty) {
        _nomeSalvo = nome;
      }

      if (email != null && email.isNotEmpty) {
        _emailSalvo = email;
      }
      if (telefone != null) _telefoneSalvo = telefone;
      if (cargo != null) _cargoSalvo = cargo;

      if (ApiService.companyId != null) {
        try {
          final empresaId = ApiService.companyId;

          if (empresaId != null && empresaId.isNotEmpty) {
            final empresa = await _buscarEmpresa(empresaId);

            final nomeEmpresa = empresa['name']?.toString().trim();

            if (nomeEmpresa != null && nomeEmpresa.isNotEmpty) {
              _empresaSalva = nomeEmpresa;
            }
          }
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() {
        nomeController.text = _nomeSalvo;
        emailController.text = _emailSalvo;
        telefoneController.text = _telefoneSalvo;
        cargoController.text = _cargoSalvo;
        empresaController.text = _empresaSalva;
        _carregando = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _buscarEmpresa(String id) async {
    final response = await ApiService.getEmpresa(id);
    return response;
  }

  Future<void> _editarFoto() async {
    await _selecionarFoto();
  }

  Future<void> _selecionarFoto() async {
    try {
      final bytes = await pickProfilePhoto();
      if (bytes == null) return;
      if (bytes.isEmpty) {
        throw Exception('O arquivo selecionado está vazio.');
      }

      await ProfilePhoto.save(bytes);
      if (mounted) _mensagem('Foto de perfil atualizada.');
    } catch (e) {
      if (mounted) {
        _mensagem(
          'Não foi possível atualizar a foto: '
          '${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  Future<void> _removerFoto() async {
    try {
      await ProfilePhoto.remove();
      if (mounted) _mensagem('Foto de perfil removida.');
    } catch (e) {
      if (mounted) {
        _mensagem(
          'Não foi possível remover a foto: '
          '${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  bool get houveMudanca {
    return nomeController.text.trim() != _nomeSalvo ||
        emailController.text.trim() != _emailSalvo ||
        telefoneController.text.trim() != _telefoneSalvo ||
        cargoController.text.trim() != _cargoSalvo ||
        empresaController.text.trim() != _empresaSalva;
  }

  bool get houveMudancaDadosPessoais {
    return nomeController.text.trim() != _nomeSalvo ||
        emailController.text.trim() != _emailSalvo ||
        telefoneController.text.trim() != _telefoneSalvo ||
        cargoController.text.trim() != _cargoSalvo;
  }

  void _voltar() {
    if (widget.aoVoltar != null) {
      widget.aoVoltar!();
    } else {
      Navigator.maybePop(context);
    }
  }

  Future<void> _salvar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final empresa = empresaController.text.trim();
    final alterouDadosPessoais = houveMudancaDadosPessoais;
    final alterouEmpresa = empresa != _empresaSalva;

    if (alterouDadosPessoais) {
      _mensagem(
        'A API não permite atualizar dados pessoais. Nome, e-mail, telefone e cargo não foram salvos.',
      );
      return;
    }

    if (alterouEmpresa && empresa.isEmpty) {
      _mensagem('Informe o nome da empresa.');
      return;
    }

    String? novoErroNome;
    String? novoErroEmail;

    if (nome.isEmpty) {
      novoErroNome = 'Informe o seu nome.';
    }

    final emailValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!emailValido) {
      novoErroEmail = 'Digite um e-mail válido.';
    }

    setState(() {
      erroNome = novoErroNome;
      erroEmail = novoErroEmail;
    });

    if (novoErroNome != null || novoErroEmail != null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _salvando = true;
    });

    try {
      if (alterouEmpresa) {
        await ApiService.atualizarEmpresa(nome: empresa);
      }

      if (!mounted) return;

      setState(() {
        if (alterouEmpresa) _empresaSalva = empresa;
        _salvando = false;
      });

      _mensagem('Empresa atualizada com sucesso!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _salvando = false;
      });

      _mensagem(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _descartar() {
    FocusScope.of(context).unfocus();

    setState(() {
      nomeController.text = _nomeSalvo;
      emailController.text = _emailSalvo;
      telefoneController.text = _telefoneSalvo;
      cargoController.text = _cargoSalvo;
      empresaController.text = _empresaSalva;
      erroNome = null;
      erroEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: c.gradFundo),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cabecalho(),
                const SizedBox(height: 24),
                _cardPerfil(),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: ProfilePhoto.image,
                  builder: (context, foto, _) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'A foto fica salva somente neste dispositivo.',
                            style: TextStyle(color: c.textoFraco, fontSize: 10),
                          ),
                        ),
                        if (foto != null)
                          TextButton.icon(
                            onPressed: _removerFoto,
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: c.vermelho,
                              size: 16,
                            ),
                            label: Text(
                              'Remover foto',
                              style: TextStyle(color: c.vermelho, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _titulo('Informações pessoais', 'Dados vinculados à sua conta'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: c.azul.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: c.azul.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: c.azul, size: 18),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Nome, e-mail, telefone e cargo estão em modo de '
                          'consulta porque a API ainda não permite alterá-los.',
                          style: TextStyle(
                            color: c.textoSuave,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _rotuloCampo('Nome completo'),
                const SizedBox(height: 8),
                _campo(
                  nomeController,
                  'Seu nome',
                  Icons.person_outline_rounded,
                  erro: erroNome,
                  capitalizacao: TextCapitalization.words,
                  somenteLeitura: true,
                ),
                const SizedBox(height: 16),
                _rotuloCampo('E-mail'),
                const SizedBox(height: 8),
                _campo(
                  emailController,
                  'seu@email.com',
                  Icons.email_outlined,
                  erro: erroEmail,
                  teclado: TextInputType.emailAddress,
                  somenteLeitura: true,
                ),
                const SizedBox(height: 16),
                _rotuloCampo('Telefone'),
                const SizedBox(height: 8),
                _campo(
                  telefoneController,
                  '(00) 00000-0000',
                  Icons.phone_outlined,
                  teclado: TextInputType.phone,
                  somenteLeitura: true,
                ),
                const SizedBox(height: 28),
                _titulo('Dados profissionais', 'Cargo e empresa'),
                const SizedBox(height: 15),
                _rotuloCampo('Cargo'),
                const SizedBox(height: 8),
                _campo(
                  cargoController,
                  'Seu cargo',
                  Icons.badge_outlined,
                  capitalizacao: TextCapitalization.words,
                  somenteLeitura: true,
                ),
                const SizedBox(height: 16),
                _rotuloCampo('Empresa'),
                const SizedBox(height: 8),
                _campo(
                  empresaController,
                  'Nome da empresa',
                  Icons.business_outlined,
                  capitalizacao: TextCapitalization.words,
                ),
                const SizedBox(height: 28),
                _botaoSalvar(),
                if (houveMudanca) ...[
                  const SizedBox(height: 10),
                  _botaoDescartar(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        GestureDetector(
          onTap: _voltar,
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.bordaMedia),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: c.texto,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppCores.gradRoxo,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: c.roxo.withAlpha(66),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MINHA CONTA',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Perfil',
                style: TextStyle(
                  color: c.texto,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardPerfil() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: c.gradDestaque,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: c.roxo.withAlpha(58)),
        boxShadow: [
          BoxShadow(
            color: c.roxo.withAlpha(37),
            blurRadius: 30,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              FotoPerfil(
                tamanho: 72,
                raio: 22,
                fallback: _iniciais(_nomeSalvo),
                tamanhoFonte: 24,
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Tooltip(
                  message: 'Alterar foto de perfil',
                  child: Material(
                    color: c.superficie,
                    shape: CircleBorder(side: BorderSide(color: c.bordaMedia)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _editarFoto,
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: c.roxoClaro,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _carregando ? 'Carregando...' : _nomeSalvo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailSalvo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textoSuave, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _selo(
                      _cargoSalvo.isEmpty ? 'Sem cargo' : _cargoSalvo,
                      c.roxoClaro,
                      Icons.badge_outlined,
                    ),
                    _selo('Conta ativa', c.verde, Icons.circle, tamanho: 6),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selo(String texto, Color cor, IconData icone, {double tamanho = 11}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withAlpha(24),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: cor.withAlpha(38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: tamanho),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: cor,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String titulo, String subtitulo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.roxoClaro, c.roxo]),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: c.texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: TextStyle(color: c.textoFraco, fontSize: 10),
              ),
            ],
          ),
        ),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: c.roxoClaro, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _rotuloCampo(String texto) {
    return Text(
      texto.toUpperCase(),
      style: TextStyle(
        color: c.textoFraco,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String hint,
    IconData icone, {
    String? erro,
    TextInputType? teclado,
    TextCapitalization capitalizacao = TextCapitalization.none,
    bool somenteLeitura = false,
  }) {
    final temErro = erro != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          readOnly: somenteLeitura,
          keyboardType: teclado,
          textCapitalization: capitalizacao,
          cursorColor: c.roxoClaro,
          style: TextStyle(color: c.texto, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textoFraco, fontSize: 12),
            prefixIcon: Icon(
              icone,
              color: temErro ? c.vermelho : c.roxoClaro,
              size: 19,
            ),
            filled: true,
            fillColor: c.fundo2,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: temErro ? c.vermelho.withAlpha(120) : c.bordaSutil,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: temErro ? c.vermelho : c.roxo.withAlpha(120),
              ),
            ),
          ),
        ),
        if (temErro) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              erro,
              style: TextStyle(
                color: c.vermelho,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _botaoSalvar() {
    final ativo = houveMudanca && !_salvando;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: ativo ? 1 : 0.5,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppCores.gradRoxo,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ativo
              ? [
                  BoxShadow(
                    color: c.roxo.withAlpha(54),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: ativo ? _salvar : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_salvando)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _salvando ? 'Salvando...' : 'Salvar alterações',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoDescartar() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _descartar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.bordaMedia),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.undo_rounded, color: c.textoSuave, size: 18),
              const SizedBox(width: 8),
              Text(
                'Descartar alterações',
                style: TextStyle(
                  color: c.textoSuave,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '?';

    if (partes.length == 1) {
      final p = partes.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            texto,
            style: TextStyle(
              color: c.texto,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: c.superficie,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: c.bordaMedia),
          ),
        ),
      );
  }
}

class FundoLateral extends StatelessWidget {
  final Widget child;

  const FundoLateral({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _FundoLateralPainter()),
          ),
        ),
      ],
    );
  }
}

class _FundoLateralPainter extends CustomPainter {
  const _FundoLateralPainter();

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant _FundoLateralPainter oldDelegate) => false;
}
