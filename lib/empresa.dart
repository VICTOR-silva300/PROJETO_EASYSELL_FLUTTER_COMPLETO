import 'package:flutter/material.dart';

import 'api_service.dart';
import 'categorias_empresa.dart';
import 'tema.dart';

class EmpresaPage extends StatefulWidget {
  const EmpresaPage({super.key});

  @override
  State<EmpresaPage> createState() => _EmpresaPageState();
}

class _EmpresaPageState extends State<EmpresaPage> {
  bool _loading = true;
  String? _erro;
  Map<String, dynamic>? _empresa;
  bool _editando = false;
  bool _salvando = false;

  final _nomeCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  AppCores get c => context.cores;

  List<String> get _opcoesCategoria {
    final atual = _categoriaCtrl.text.trim();
    if (atual.isEmpty || categoriasEmpresa.contains(atual)) {
      return categoriasEmpresa;
    }
    return [...categoriasEmpresa, atual];
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cnpjCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final id = ApiService.companyId;
      if (id == null || id.isEmpty) {
        setState(() {
          _empresa = null;
          _loading = false;
          _editando = true;
        });
        return;
      }
      final data = await ApiService.getEmpresa(id);
      if (!mounted) return;
      _nomeCtrl.text = (data['name'] ?? data['nome'] ?? '').toString();
      _cnpjCtrl.text = (data['cnpj'] ?? '').toString();
      _categoriaCtrl.text = (data['categoria'] ?? data['category'] ?? '')
          .toString();
      setState(() {
        _empresa = data;
        _loading = false;
        _editando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _salvar() async {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da empresa')),
      );
      return;
    }
    setState(() => _salvando = true);
    try {
      final empresaId = ApiService.companyId;
      if (empresaId == null || empresaId.isEmpty) {
        throw Exception(
          'Esta conta ainda não tem uma empresa vinculada. Conclua o cadastro '
          'da empresa para continuar.',
        );
      }

      await ApiService.atualizarEmpresa(
        nome: nome,
        cnpj: _cnpjCtrl.text,
        categoria: _categoriaCtrl.text,
      );
      final confirmada = await ApiService.getEmpresa(empresaId);
      if ((confirmada['name'] ?? confirmada['nome'] ?? '').toString().trim() !=
              nome ||
          (confirmada['cnpj'] ?? '').toString().trim() !=
              _cnpjCtrl.text.trim() ||
          (confirmada['categoria'] ?? confirmada['category'] ?? '')
                  .toString()
                  .trim() !=
              _categoriaCtrl.text.trim()) {
        throw Exception(
          'A API não confirmou os dados da empresa. Verifique se o servidor '
          'permite atualizar nome, CNPJ e categoria.',
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dados da empresa salvos')));
      await _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _carregar,
        color: c.roxo,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(19, 15, 19, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _cabecalho(),
                    const SizedBox(height: 27),
                    _tituloPagina(),
                    const SizedBox(height: 21),
                    if (_loading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 70),
                        child: Center(
                          child: CircularProgressIndicator(color: c.roxo),
                        ),
                      )
                    else if (_erro != null)
                      _cartaoErro()
                    else ...[
                      _destaqueEmpresa(),
                      const SizedBox(height: 20),
                      _cartaoDados(),
                      if (_empresa != null) ...[
                        const SizedBox(height: 14),
                        _info(
                          'Identificador da empresa',
                          (_empresa!['_id'] ?? _empresa!['id'] ?? '—')
                              .toString(),
                        ),
                      ],
                      if (_editando || _empresa == null) ...[
                        const SizedBox(height: 18),
                        _acoesEdicao(),
                      ],
                    ],
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppCores.gradRoxo,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: c.roxo.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.business_rounded,
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
                'ORGANIZAÇÃO',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Empresa',
                style: TextStyle(
                  color: c.texto,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Atualizar dados da empresa',
          onPressed: _loading ? null : _carregar,
          style: IconButton.styleFrom(
            foregroundColor: c.roxo,
            backgroundColor: c.superficie,
            fixedSize: const Size(43, 43),
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
        if (!_loading && _empresa != null && !_editando) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Editar dados da empresa',
            onPressed: () => setState(() => _editando = true),
            icon: const Icon(Icons.edit_rounded),
            style: IconButton.styleFrom(
              foregroundColor: c.roxo,
              backgroundColor: c.roxo.withValues(alpha: 0.1),
              fixedSize: const Size(43, 43),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tituloPagina() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua empresa 🏢',
          style: TextStyle(
            color: c.texto,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Gerencie os dados e a atividade do seu negócio.',
          style: TextStyle(color: c.textoSuave, fontSize: 12),
        ),
        const SizedBox(height: 15),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.roxo, c.roxoClaro]),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _destaqueEmpresa() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: c.gradDestaque,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.roxo.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: c.roxo.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.apartment_rounded, color: c.roxoClaro, size: 18),
              const SizedBox(width: 8),
              Text(
                'PERFIL DA EMPRESA',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nomeCtrl,
            builder: (context, value, _) {
              final nome = value.text.trim();
              return Text(
                nome.isEmpty ? 'Nome da sua empresa' : nome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.texto,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          Text(
            _categoriaCtrl.text.trim().isEmpty
                ? 'Informações do seu negócio'
                : _categoriaCtrl.text.trim(),
            style: TextStyle(color: c.textoSuave, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _cartaoDados() {
    final habilitado = _editando || _empresa == null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: c.gradCard,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: c.bordaSutil),
        boxShadow: [
          BoxShadow(
            color: c.ehEscuro
                ? Colors.black.withValues(alpha: 0.12)
                : c.roxo.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DADOS CADASTRAIS',
            style: TextStyle(
              color: c.textoFraco,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          _campo(
            'Nome da empresa',
            _nomeCtrl,
            enabled: habilitado,
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 14),
          _campo(
            'CNPJ',
            _cnpjCtrl,
            enabled: habilitado,
            keyboard: TextInputType.number,
            icon: Icons.numbers_rounded,
          ),
          const SizedBox(height: 14),
          _campoCategoria(enabled: habilitado),
        ],
      ),
    );
  }

  Widget _campoCategoria({required bool enabled}) {
    final categoriaAtual = _categoriaCtrl.text.trim();
    return DropdownButtonFormField<String>(
      initialValue: _opcoesCategoria.contains(categoriaAtual)
          ? categoriaAtual
          : null,
      isExpanded: true,
      items: _opcoesCategoria
          .map(
            (categoria) => DropdownMenuItem(
              value: categoria,
              child: Text(categoria, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (categoria) {
              if (categoria == null) return;
              setState(() => _categoriaCtrl.text = categoria);
            }
          : null,
      decoration: InputDecoration(
        labelText: 'Categoria da empresa',
        prefixIcon: Icon(
          Icons.category_outlined,
          color: enabled ? c.roxo : c.textoFraco,
        ),
        filled: true,
        fillColor: enabled ? c.fundo2 : c.fundo,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.bordaSutil),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.roxo, width: 1.5),
        ),
      ),
    );
  }

  Widget _cartaoErro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.vermelho.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.vermelho.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: c.vermelho),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_erro!, style: TextStyle(color: c.texto)),
          ),
          IconButton(
            tooltip: 'Tentar novamente',
            onPressed: _carregar,
            icon: Icon(Icons.refresh_rounded, color: c.roxo),
          ),
        ],
      ),
    );
  }

  Widget _acoesEdicao() {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: _salvando ? null : _salvar,
          icon: _salvando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            _salvando ? 'Salvando...' : 'Salvar alterações',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: c.roxo,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
        if (_empresa != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: _salvando
                ? null
                : () {
                    _nomeCtrl.text =
                        (_empresa!['name'] ?? _empresa!['nome'] ?? '')
                            .toString();
                    _cnpjCtrl.text = (_empresa!['cnpj'] ?? '').toString();
                    _categoriaCtrl.text =
                        (_empresa!['categoria'] ?? _empresa!['category'] ?? '')
                            .toString();
                    setState(() => _editando = false);
                  },
            child: const Text('Cancelar'),
          ),
        ],
      ],
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    bool enabled = true,
    TextInputType? keyboard,
    required IconData icon,
  }) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? c.roxo : c.textoFraco),
        filled: true,
        fillColor: enabled ? c.fundo2 : c.fundo,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.bordaSutil),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.roxo, width: 1.5),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: c.gradCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.bordaSutil),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: c.textoSuave, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: c.texto, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
