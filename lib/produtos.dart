import 'package:flutter/material.dart';

import 'icone_categoria.dart';
import 'tema.dart';
import 'api_service.dart';

class Produtos extends StatefulWidget {
  const Produtos({super.key});

  @override
  State<Produtos> createState() => _ProdutosState();
}

class _ProdutosState extends State<Produtos> {
  AppCores get c => context.cores;

  static const List<String> categorias = [
    'Eletrônicos',
    'Periféricos',
    'Informática',
    'Celulares',
    'Áudio',
    'Games',
    'Casa e Decoração',
    'Escritório',
    'Moda',
    'Beleza',
    'Esportes',
    'Alimentos',
    'Bebidas',
    'Automotivo',
    'Ferramentas',
    'Pet Shop',
    'Infantil',
    'Livros',
    'Saúde',
    'Outros',
  ];

  static const List<String> filtros = [
    'Todos',
    'Ativos',
    'Inativos',
    ...categorias,
  ];

  final TextEditingController pesquisaController = TextEditingController();

  String filtro = 'Todos';

  final List<Map<String, dynamic>> produtos = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    try {
      final dados = await ApiService.produtos();

      if (!mounted) return;

      setState(() {
        produtos
          ..clear()
          ..addAll(dados.map(_mapProduto));

        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      _mensagem(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Map<String, dynamic> _mapProduto(Map<String, dynamic> item) {
    final categoria = categorias.contains(item['categoria']?.toString())
        ? item['categoria'].toString()
        : 'Outros';

    final estoque = _numero(item['quantidade']).round();

    return {
      ...item,
      'id': item['_id']?.toString(),
      'nome': item['name']?.toString() ?? '',
      'categoria': categoria,
      'preco': _numero(item['preco']),
      'estoque': estoque,
      'ativo': estoque > 0,
      'cor': _corCategoriaChave(categoria),
      'icon': _iconeCategoria(categoria),
    };
  }

  double _numero(dynamic valor) {
    return valor is num
        ? valor.toDouble()
        : double.tryParse(valor?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  String _corCategoriaChave(String categoria) {
    switch (categoria) {
      case 'Eletrônicos':
      case 'Celulares':
      case 'Informática':
        return 'azul';

      case 'Periféricos':
      case 'Games':
      case 'Esportes':
        return 'verde';

      case 'Áudio':
      case 'Bebidas':
      case 'Moda':
        return 'amarelo';

      case 'Beleza':
      case 'Infantil':
      case 'Pet Shop':
        return 'rosa';

      case 'Casa e Decoração':
      case 'Escritório':
      case 'Livros':
        return 'roxo';

      case 'Alimentos':
      case 'Saúde':
        return 'verde';

      case 'Automotivo':
      case 'Ferramentas':
        return 'laranja';

      default:
        return 'azul';
    }
  }

  IconData _iconeCategoria(String categoria) {
    return iconeCategoria(categoria);
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  Color corClara(Color cor, int alpha) {
    return cor.withAlpha(alpha);
  }

  Color _cor(String chave) {
    switch (chave) {
      case 'azul':
        return c.azul;

      case 'verde':
        return c.verde;

      case 'amarelo':
        return c.amarelo;

      case 'vermelho':
        return c.vermelho;

      case 'rosa':
        return const Color(0xFFEC4899);

      case 'roxo':
        return c.roxoClaro;

      case 'laranja':
        return const Color(0xFFF97316);

      default:
        return c.roxoClaro;
    }
  }

  BoxDecoration _decoracaoCard({double raio = 24}) {
    return BoxDecoration(
      gradient: c.gradCard,
      borderRadius: BorderRadius.circular(raio),
      border: Border.all(color: c.bordaSutil),
    );
  }

  List<Map<String, dynamic>> get produtosFiltrados {
    final pesquisa = pesquisaController.text.toLowerCase().trim();

    return produtos.where((produto) {
      final nome = produto['nome'].toString().toLowerCase();

      final categoria = produto['categoria'].toString().toLowerCase();

      final correspondePesquisa =
          nome.contains(pesquisa) || categoria.contains(pesquisa);

      bool correspondeFiltro = true;

      if (filtro == 'Ativos') {
        correspondeFiltro = produto['ativo'] == true;
      } else if (filtro == 'Inativos') {
        correspondeFiltro = produto['ativo'] != true;
      } else if (categorias.contains(filtro)) {
        correspondeFiltro = produto['categoria'] == filtro;
      }

      return correspondePesquisa && correspondeFiltro;
    }).toList();
  }

  int get totalProdutos => produtos.length;

  int get produtosAtivos => produtos.where((p) => p['ativo'] == true).length;

  int get produtosInativos => produtos.where((p) => p['ativo'] != true).length;

  String _preco(dynamic valor) {
    final partes = (valor as num).toStringAsFixed(2).split('.');

    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );

    return 'R\$ $inteiro,${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final lista = produtosFiltrados;

    return Scaffold(
      backgroundColor: Colors.transparent,

      floatingActionButton: _botaoAdicionar(),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(19, 15, 19, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _cabecalho(),

                    const SizedBox(height: 27),

                    _tituloPagina(),

                    const SizedBox(height: 21),

                    _resumo(),

                    const SizedBox(height: 25),

                    _barraPesquisa(),

                    const SizedBox(height: 29),

                    _tituloSecao(lista.length),

                    const SizedBox(height: 13),

                    _listaProdutos(lista),

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
            boxShadow: const [
              BoxShadow(
                color: Color(0x422563EB),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
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
                'GERENCIAMENTO',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Produtos',
                style: TextStyle(
                  color: c.texto,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _botaoCabecalho(
          icon: Icons.notifications_rounded,
          onTap: _abrirNotificacoes,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _botaoCabecalho({
    required IconData icon,
    required VoidCallback onTap,
    bool notificacao = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.bordaMedia),
            ),
            child: Icon(icon, color: c.texto, size: 20),
          ),
          if (notificacao)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: c.vermelho,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.superficie, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tituloPagina() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seus produtos 📦',
          style: TextStyle(
            color: c.texto,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Acompanhe e gerencie todos os produtos do seu negócio.',
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

  Widget _resumo() {
    return Row(
      children: [
        Expanded(
          child: _cardResumo(
            icon: Icons.inventory_2_outlined,
            titulo: 'Produtos',
            valor: totalProdutos.toString(),
            detalhe: 'TOTAL',
            cor: c.roxoClaro,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _cardResumo(
            icon: Icons.check_circle_outline_rounded,
            titulo: 'Ativos',
            valor: produtosAtivos.toString(),
            detalhe: 'Concluídos',
            cor: c.verde,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _cardResumo(
            icon: Icons.pause_circle_outline_rounded,
            titulo: 'Inativos',
            valor: produtosInativos.toString().padLeft(2, '0'),
            detalhe: 'Desativados',
            cor: c.vermelho,
          ),
        ),
      ],
    );
  }

  Widget _cardResumo({
    required IconData icon,
    required String titulo,
    required String valor,
    required String detalhe,
    required Color cor,
  }) {
    return Container(
      height: 133,
      padding: const EdgeInsets.all(13),
      decoration: _decoracaoCard(raio: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: corClara(cor, 27),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cor, size: 18),
              ),
              const Spacer(),
              Icon(Icons.arrow_upward_rounded, color: cor, size: 13),
            ],
          ),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              color: c.texto,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textoSuave, fontSize: 9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: corClara(cor, 25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  detalhe,
                  style: TextStyle(
                    color: cor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barraPesquisa() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: c.bordaMedia),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: c.textoFraco, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: TextField(
              controller: pesquisaController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: c.texto, fontSize: 12),
              cursorColor: c.roxoClaro,
              decoration: InputDecoration(
                hintText: 'Pesquisar produto...',
                hintStyle: TextStyle(color: c.textoFraco, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (pesquisaController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                pesquisaController.clear();
                setState(() {});
              },
              child: Icon(Icons.close_rounded, color: c.textoSuave, size: 19),
            ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _abrirFiltros,
            child: Icon(
              Icons.tune_rounded,
              color: filtro == 'Todos' ? c.roxoClaro : c.verde,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSecao(int quantidade) {
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
                'Produtos',
                style: TextStyle(
                  color: c.texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                filtro == 'Todos'
                    ? '$quantidade produtos encontrados'
                    : '$filtro • $quantidade encontrados',
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

  Widget _listaProdutos(List<Map<String, dynamic>> lista) {
    if (lista.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: _decoracaoCard(),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: corClara(c.roxoClaro, 27),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: c.roxoClaro,
                size: 28,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Nenhum produto encontrado',
              style: TextStyle(
                color: c.texto,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tente pesquisar outro produto.',
              style: TextStyle(color: c.textoSuave, fontSize: 10),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: _decoracaoCard(),
      child: Column(
        children: [
          for (int i = 0; i < lista.length; i++) ...[
            _produtoCard(lista[i]),
            if (i != lista.length - 1) _divisor(),
          ],
        ],
      ),
    );
  }

  Widget _produtoCard(Map<String, dynamic> produto) {
    final Color cor = _cor(produto['cor']);

    final int estoque = produto['estoque'];

    final bool ativo = produto['ativo'] == true;

    final Color corStatus = ativo ? c.verde : c.vermelho;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _abrirDetalhes(produto),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: corClara(cor, 30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: corClara(cor, 38)),
                ),
                child: Icon(produto['icon'], color: cor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto['nome'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.texto,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(produto['icon'], color: cor, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            produto['categoria'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: c.textoFraco, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$estoque unidades',
                      style: TextStyle(
                        color: cor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _preco(produto['preco']),
                    style: TextStyle(
                      color: c.texto,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: corClara(corStatus, 24),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: corClara(corStatus, 40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ativo
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_rounded,
                          color: corStatus,
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ativo ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                            color: corStatus,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              Icon(Icons.chevron_right_rounded, color: c.textoFraco, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divisor() {
    return Padding(
      padding: const EdgeInsets.only(left: 75),
      child: Divider(color: c.bordaSutil, height: 1),
    );
  }

  Widget _botaoAdicionar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppCores.gradRoxo,
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(
            color: Color(0x552563EB),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _adicionarProduto,
          borderRadius: BorderRadius.circular(19),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 9),
                Text(
                  'Adicionar produto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoPrincipal({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppCores.gradRoxo,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x357C3AED),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
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
    );
  }

  Future<void> _sheet({required Widget child, double alturaMaxima = 0.86}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * alturaMaxima,
          ),
          decoration: BoxDecoration(
            gradient: c.gradSheet,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                22,
                12,
                22,
                28 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.textoFraco,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tituloSheet(String titulo, String subtitulo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: c.texto,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(subtitulo, style: TextStyle(color: c.textoSuave, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _chipSelecao(
    String label,
    bool selecionado,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          gradient: selecionado
              ? const LinearGradient(
                  colors: [Color(0x322563EB), Color(0x182563EB)],
                )
              : null,
          color: selecionado ? null : c.superficie,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selecionado ? const Color(0x552563EB) : c.bordaSutil,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: selecionado ? c.roxoClaro : c.textoSuave,
                size: 15,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selecionado ? c.texto : c.textoSuave,
                fontSize: 10,
                fontWeight: selecionado ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirFiltros() {
    _sheet(
      alturaMaxima: 0.85,
      child: Column(
        children: [
          _tituloSheet(
            'Filtrar produtos',
            'Escolha quais produtos deseja visualizar',
          ),
          const SizedBox(height: 21),
          Wrap(
            children: [
              _chipFiltroSheet('Todos'),
              _chipFiltroSheet('Ativos'),
              _chipFiltroSheet('Inativos'),
              ...categorias.map(
                (categoria) => _chipFiltroSheet(
                  categoria,
                  icon: _iconeCategoria(categoria),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipFiltroSheet(String texto, {IconData? icon}) {
    final selecionado = texto == filtro;

    return _chipSelecao(texto, selecionado, () {
      setState(() {
        filtro = texto;
      });

      Navigator.pop(context);
    }, icon: icon);
  }

  void _abrirDetalhes(Map<String, dynamic> produto) {
    final precoController = TextEditingController(
      text: (produto['preco'] as num).toStringAsFixed(2).replaceAll('.', ','),
    );

    final estoqueController = TextEditingController(
      text: '${produto['estoque']}',
    );

    String categoriaSel = categorias.contains(produto['categoria'])
        ? produto['categoria']
        : 'Outros';

    bool ativo = produto['ativo'] == true;

    String? erro;

    _sheet(
      alturaMaxima: 0.96,
      child: StatefulBuilder(
        builder: (context, setSheet) {
          void ajustarEstoque(int delta) {
            final atual = int.tryParse(estoqueController.text.trim()) ?? 0;

            final novo = (atual + delta) < 0 ? 0 : atual + delta;

            setSheet(() {
              estoqueController.text = '$novo';

              ativo = novo > 0;
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: corClara(_cor(_corCategoriaChave(categoriaSel)), 30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: corClara(
                        _cor(_corCategoriaChave(categoriaSel)),
                        38,
                      ),
                    ),
                  ),
                  child: Icon(
                    _iconeCategoria(categoriaSel),
                    color: _cor(_corCategoriaChave(categoriaSel)),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  produto['nome'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  categoriaSel,
                  style: TextStyle(color: c.textoSuave, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              _rotuloCampo('Categoria'),
              const SizedBox(height: 10),
              Wrap(
                children: categorias.map((categoria) {
                  return _chipSelecao(
                    categoria,
                    categoriaSel == categoria,
                    () {
                      setSheet(() {
                        categoriaSel = categoria;
                      });
                    },
                    icon: _iconeCategoria(categoria),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _rotuloCampo('Preço'),
              const SizedBox(height: 8),
              _campo(
                precoController,
                'Ex.: 289,90',
                Icons.payments_outlined,
                teclado: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              _rotuloCampo('Estoque'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _botaoQuadrado(
                    Icons.remove_rounded,
                    () => ajustarEstoque(-1),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: estoqueController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      cursorColor: c.roxoClaro,
                      onChanged: (valor) {
                        final quantidade = int.tryParse(valor) ?? 0;

                        setSheet(() {
                          ativo = quantidade > 0;
                        });
                      },
                      style: TextStyle(
                        color: c.texto,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        suffixText: 'un.',
                        suffixStyle: TextStyle(
                          color: c.textoFraco,
                          fontSize: 11,
                        ),
                        filled: true,
                        fillColor: c.fundo2,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: c.bordaSutil),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0x552563EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _botaoQuadrado(Icons.add_rounded, () => ajustarEstoque(1)),
                ],
              ),
              const SizedBox(height: 16),
              _rotuloCampo('Status'),
              const SizedBox(height: 10),
              Wrap(
                children: [
                  _chipSelecao('Ativo', ativo, () {
                    setSheet(() {
                      ativo = true;

                      final estoque =
                          int.tryParse(estoqueController.text.trim()) ?? 0;

                      if (estoque <= 0) {
                        estoqueController.text = '1';
                      }
                    });
                  }, icon: Icons.check_circle_rounded),
                  _chipSelecao('Inativo', !ativo, () {
                    setSheet(() {
                      ativo = false;
                      estoqueController.text = '0';
                    });
                  }, icon: Icons.pause_circle_rounded),
                ],
              ),
              if (erro != null) ...[
                const SizedBox(height: 4),
                Text(
                  erro!,
                  style: TextStyle(
                    color: c.vermelho,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _botaoPrincipal(
                label: 'Salvar alterações',
                icon: Icons.check_rounded,
                onTap: () async {
                  final preco = _lerValor(precoController.text);

                  int? estoque = int.tryParse(estoqueController.text.trim());

                  if (preco == null || preco < 0) {
                    setSheet(() {
                      erro = 'Digite um preço válido.';
                    });
                    return;
                  }

                  if (estoque == null || estoque < 0) {
                    setSheet(() {
                      erro = 'Informe uma quantidade válida.';
                    });
                    return;
                  }

                  if (ativo && estoque == 0) {
                    estoque = 1;

                    setSheet(() {
                      estoqueController.text = '1';
                    });
                  }

                  if (!ativo) {
                    estoque = 0;

                    setSheet(() {
                      estoqueController.text = '0';
                    });
                  }

                  final id = produto['id']?.toString();

                  if (id == null || id.isEmpty) {
                    setSheet(() {
                      erro = 'Produto sem identificador no banco.';
                    });
                    return;
                  }

                  try {
                    final atualizado = await ApiService.atualizarProduto(
                      id,
                      preco: preco,
                      quantidade: estoque,
                      categoria: categoriaSel,
                    );

                    if (!mounted) return;

                    setState(() {
                      final index = produtos.indexOf(produto);

                      if (index >= 0) {
                        produtos[index] = _mapProduto(atualizado);
                      }
                    });

                    Navigator.pop(context);

                    _mensagem('Produto atualizado!');
                  } catch (e) {
                    setSheet(() {
                      erro = e.toString().replaceFirst('Exception: ', '');
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      precoController.dispose();
      estoqueController.dispose();
    });
  }

  Widget _botaoQuadrado(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0x207C3AED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x357C3AED)),
          ),
          child: Icon(icon, color: c.roxoClaro, size: 22),
        ),
      ),
    );
  }

  void _abrirNotificacoes() {
    _sheet(
      alturaMaxima: 0.7,
      child: Column(
        children: [
          _tituloSheet('Notificações', 'Avisos importantes dos seus produtos'),
          const SizedBox(height: 20),
          _itemLista(
            icon: Icons.pause_circle_outline_rounded,
            titulo: 'Produtos inativos',
            subtitulo: '$produtosInativos produtos estão inativos.',
            cor: c.vermelho,
          ),
          _itemLista(
            icon: Icons.inventory_2_outlined,
            titulo: 'Produtos ativos',
            subtitulo: '$produtosAtivos produtos estão ativos.',
            cor: c.verde,
          ),
        ],
      ),
    );
  }

  void _abrirMenu() {
    _sheet(
      alturaMaxima: 0.7,
      child: Builder(
        builder: (sheetContext) {
          return Column(
            children: [
              _tituloSheet(
                'Configurações de Produtos',
                'Gerencie seus produtos rapidamente',
              ),
              const SizedBox(height: 21),
              _itemLista(
                icon: Icons.add_box_outlined,
                titulo: 'Adicionar produto',
                subtitulo: 'Cadastre um novo produto',
                cor: c.roxoClaro,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _adicionarProduto();
                },
              ),
              _itemLista(
                icon: Icons.filter_alt_outlined,
                titulo: 'Filtrar produtos',
                subtitulo: 'Escolha o que deseja visualizar',
                cor: c.azul,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _abrirFiltros();
                },
              ),
              _itemLista(
                icon: Icons.filter_alt_off_outlined,
                titulo: 'Limpar filtros',
                subtitulo: 'Voltar a mostrar todos os produtos',
                cor: c.verde,
                onTap: () {
                  Navigator.pop(sheetContext);

                  pesquisaController.clear();

                  setState(() {
                    filtro = 'Todos';
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _itemLista({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color cor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: c.fundo2,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: c.bordaSutil),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: corClara(cor, 28),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: cor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          color: c.texto,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: TextStyle(color: c.textoSuave, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: c.textoFraco,
                    size: 15,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _adicionarProduto() {
    final nomeController = TextEditingController();

    final precoController = TextEditingController();

    final estoqueController = TextEditingController();

    String categoriaSel = categorias.first;

    String? erro;

    _sheet(
      alturaMaxima: 0.94,
      child: StatefulBuilder(
        builder: (context, setSheet) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tituloSheet('Novo produto', 'Cadastre um produto no EasySell'),
              const SizedBox(height: 21),
              _rotuloCampo('Nome do produto'),
              const SizedBox(height: 8),
              _campo(
                nomeController,
                'Ex.: Notebook Pro',
                Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 16),
              _rotuloCampo('Preço'),
              const SizedBox(height: 8),
              _campo(
                precoController,
                'Ex.: 289,90',
                Icons.payments_outlined,
                teclado: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              _rotuloCampo('Quantidade em estoque'),
              const SizedBox(height: 8),
              _campo(
                estoqueController,
                'Ex.: 20',
                Icons.inventory_outlined,
                teclado: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _rotuloCampo('Categoria'),
              const SizedBox(height: 10),
              Wrap(
                children: categorias.map((categoria) {
                  return _chipSelecao(
                    categoria,
                    categoriaSel == categoria,
                    () {
                      setSheet(() {
                        categoriaSel = categoria;
                      });
                    },
                    icon: _iconeCategoria(categoria),
                  );
                }).toList(),
              ),
              if (erro != null) ...[
                const SizedBox(height: 4),
                Text(
                  erro!,
                  style: TextStyle(
                    color: c.vermelho,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _botaoPrincipal(
                label: 'Adicionar produto',
                icon: Icons.check_rounded,
                onTap: () async {
                  final nome = nomeController.text.trim();

                  final preco = _lerValor(precoController.text);

                  final estoque = int.tryParse(estoqueController.text.trim());

                  if (nome.isEmpty) {
                    setSheet(() {
                      erro = 'Informe o nome do produto.';
                    });
                    return;
                  }

                  if (preco == null || preco < 0) {
                    setSheet(() {
                      erro = 'Digite um preço válido.';
                    });
                    return;
                  }

                  if (estoque == null || estoque < 0) {
                    setSheet(() {
                      erro = 'Informe a quantidade em estoque.';
                    });
                    return;
                  }

                  try {
                    final criado = await ApiService.criarProduto(
                      nome: nome,
                      categoria: categoriaSel,
                      preco: preco,
                      quantidade: estoque,
                    );

                    if (!mounted) return;

                    setState(() {
                      produtos.insert(0, _mapProduto(criado));
                    });

                    Navigator.pop(context);

                    _mensagem('Produto adicionado!');
                  } catch (e) {
                    setSheet(() {
                      erro = e.toString().replaceFirst('Exception: ', '');
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      nomeController.dispose();
      precoController.dispose();
      estoqueController.dispose();
    });
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
    IconData icon, {
    TextInputType? teclado,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      cursorColor: c.roxoClaro,
      style: TextStyle(color: c.texto, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textoFraco, fontSize: 12),
        prefixIcon: Icon(icon, color: c.roxoClaro, size: 19),
        filled: true,
        fillColor: c.fundo2,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.bordaSutil),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x552563EB)),
        ),
      ),
    );
  }

  double? _lerValor(String texto) {
    var t = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');

    if (t.contains(',')) {
      t = t.replaceAll('.', '').replaceAll(',', '.');
    }

    return double.tryParse(t);
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            texto,
            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF181F31),
          duration: const Duration(milliseconds: 1600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0x18FFFFFF)),
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
