import 'package:flutter/material.dart';

import 'api_service.dart';
import 'icone_categoria.dart';
import 'tema.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  bool _loading = true;
  String? _erro;
  List<Map<String, dynamic>> _itens = [];
  String _busca = '';

  AppCores get c => context.cores;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final lista = await ApiService.produtos();
      if (!mounted) return;
      setState(() {
        _itens = lista;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  int _qtd(Map<String, dynamic> produto) {
    final quantidade =
        produto['quantidade'] ?? produto['stock'] ?? produto['qtd'] ?? 0;
    if (quantidade is num) return quantidade.toInt();
    return int.tryParse('$quantidade') ?? 0;
  }

  String _nome(Map<String, dynamic> produto) =>
      (produto['name'] ?? produto['nome'] ?? 'Produto').toString();

  String _categoria(Map<String, dynamic> produto) =>
      (produto['categoria'] ?? 'Outros').toString();

  List<Map<String, dynamic>> get _filtrados {
    final busca = _busca.trim().toLowerCase();
    if (busca.isEmpty) return _itens;
    return _itens.where((produto) {
      return _nome(produto).toLowerCase().contains(busca) ||
          _categoria(produto).toLowerCase().contains(busca);
    }).toList();
  }

  int get _unidadesTotais =>
      _itens.fold(0, (total, produto) => total + _qtd(produto));

  int get _estoqueBaixo =>
      _itens.where((produto) => _qtd(produto) <= 10).length;

  BoxDecoration _decoracaoCard({double raio = 24}) {
    return BoxDecoration(
      gradient: c.gradCard,
      borderRadius: BorderRadius.circular(raio),
      border: Border.all(color: c.bordaSutil),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produtos = _filtrados;

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
                    _resumo(),
                    const SizedBox(height: 25),
                    _barraPesquisa(),
                    const SizedBox(height: 29),
                    _tituloSecao(produtos.length),
                    const SizedBox(height: 13),
                    _conteudo(produtos),
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
                color: c.roxo.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 8),
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
                'Estoque',
                style: TextStyle(
                  color: c.texto,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _loading ? null : _carregar,
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.bordaMedia),
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: _loading ? c.textoFraco : c.texto,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tituloPagina() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seu estoque 📦',
          style: TextStyle(
            color: c.texto,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Acompanhe quantidades e reposições dos seus produtos.',
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
            valor: '${_itens.length}',
            detalhe: 'TOTAL',
            cor: c.roxoClaro,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _cardResumo(
            icon: Icons.widgets_outlined,
            titulo: 'Unidades',
            valor: '$_unidadesTotais',
            detalhe: 'EM ESTOQUE',
            cor: c.azul,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _cardResumo(
            icon: Icons.warning_amber_rounded,
            titulo: 'Estoque baixo',
            valor: '$_estoqueBaixo',
            detalhe: 'ATENÇÃO',
            cor: _estoqueBaixo > 0 ? c.vermelho : c.verde,
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
                  color: cor.withValues(alpha: 0.11),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textoSuave, fontSize: 9),
                ),
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  detalhe,
                  style: TextStyle(
                    color: cor,
                    fontSize: 7,
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
              onChanged: (valor) => setState(() => _busca = valor),
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
          if (_busca.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _busca = ''),
              child: Icon(Icons.close_rounded, color: c.textoSuave, size: 19),
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
                'Estoque',
                style: TextStyle(
                  color: c.texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$quantidade produtos encontrados',
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

  Widget _conteudo(List<Map<String, dynamic>> produtos) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_erro != null) {
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

    if (produtos.isEmpty) {
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
                color: c.roxoClaro.withValues(alpha: 0.11),
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
          for (var i = 0; i < produtos.length; i++) ...[
            _produtoCard(produtos[i]),
            if (i != produtos.length - 1) _divisor(),
          ],
        ],
      ),
    );
  }

  Widget _produtoCard(Map<String, dynamic> produto) {
    final quantidade = _qtd(produto);
    final baixo = quantidade <= 10;
    final categoria = _categoria(produto);
    final cor = baixo ? c.vermelho : c.roxoClaro;
    final icone = iconeCategoria(categoria);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cor.withValues(alpha: 0.15)),
            ),
            child: Icon(icone, color: cor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nome(produto),
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
                    Icon(icone, color: cor, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        categoria,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.textoFraco, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$quantidade un.',
                style: TextStyle(
                  color: baixo ? c.vermelho : c.texto,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  baixo ? 'BAIXO' : 'DISPONÍVEL',
                  style: TextStyle(
                    color: cor,
                    fontSize: 7,
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

  Widget _divisor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(height: 1, color: c.bordaSutil),
    );
  }
}
