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

  int _qtd(Map<String, dynamic> p) {
    final q = p['quantidade'] ?? p['stock'] ?? p['qtd'] ?? 0;
    if (q is num) return q.toInt();
    return int.tryParse('$q') ?? 0;
  }

  String _nome(Map<String, dynamic> p) =>
      (p['name'] ?? p['nome'] ?? 'Produto').toString();

  List<Map<String, dynamic>> get _filtrados {
    final q = _busca.trim().toLowerCase();
    if (q.isEmpty) return _itens;
    return _itens.where((p) => _nome(p).toLowerCase().contains(q)).toList();
  }

  int get _unidadesTotais =>
      _itens.fold(0, (total, produto) => total + _qtd(produto));

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
    final baixos = _itens.where((p) => _qtd(p) <= 10).length;

    return RefreshIndicator(
      onRefresh: _carregar,
      color: c.roxo,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: c.gradDestaque,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: c.roxo.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: c.roxo.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppCores.gradRoxo,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: c.roxo.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTROLE DE PRODUTOS',
                        style: TextStyle(
                          color: c.textoFraco,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Estoque',
                        style: TextStyle(
                          color: c.texto,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Acompanhe quantidades e reposições',
                        style: TextStyle(color: c.textoSuave, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Atualizar estoque',
                      onPressed: _loading ? null : _carregar,
                      style: IconButton.styleFrom(
                        foregroundColor: c.roxo,
                        backgroundColor: c.superficie.withValues(alpha: 0.8),
                        fixedSize: const Size(42, 42),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _IndicadorEstoque(
                  titulo: 'Produtos',
                  valor: '${_itens.length}',
                  icon: Icons.inventory_2_outlined,
                  cor: c.roxo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IndicadorEstoque(
                  titulo: 'Unidades',
                  valor: '$_unidadesTotais',
                  icon: Icons.widgets_outlined,
                  cor: c.azul,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IndicadorEstoque(
                  titulo: 'Estoque baixo',
                  valor: '$baixos',
                  icon: Icons.warning_amber_rounded,
                  cor: baixos > 0 ? c.vermelho : c.verde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => _busca = v),
            decoration: InputDecoration(
              hintText: 'Buscar produto por nome...',
              prefixIcon: Icon(Icons.search_rounded, color: c.roxo),
              filled: true,
              fillColor: c.fundo2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: c.bordaSutil),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: c.bordaSutil),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: c.roxo, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!_loading && _erro == null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: c.gradCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: (baixos > 0 ? c.vermelho : c.verde).withValues(
                    alpha: 0.25,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (baixos > 0 ? c.vermelho : c.verde).withValues(
                      alpha: c.ehEscuro ? 0.07 : 0.035,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    baixos > 0
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: baixos > 0 ? c.vermelho : c.verde,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      baixos > 0
                          ? '$baixos produto(s) com 10 ou menos unidades'
                          : 'Estoque saudável em todos os produtos',
                      style: TextStyle(
                        color: c.texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          if (!_loading && _erro == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Text(
                'PRODUTOS (${filtrados.length})',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_erro != null)
            Container(
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
            )
          else if (filtrados.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Nenhum produto encontrado',
                  style: TextStyle(color: c.textoSuave),
                ),
              ),
            )
          else
            ...filtrados.map((p) {
              final qtd = _qtd(p);
              final baixo = qtd <= 10;
              return Container(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: c.gradCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: baixo
                        ? c.vermelho.withValues(alpha: 0.35)
                        : c.bordaSutil,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baixo
                          ? c.vermelho.withValues(alpha: 0.045)
                          : Colors.black.withValues(
                              alpha: c.ehEscuro ? 0.08 : 0.025,
                            ),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (baixo ? c.vermelho : c.roxo).withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconeCategoria((p['categoria'] ?? 'Outros').toString()),
                        color: baixo ? c.vermelho : c.roxo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nome(p),
                            style: TextStyle(
                              color: c.texto,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (p['categoria'] ?? 'Sem categoria').toString(),
                            style: TextStyle(color: c.textoSuave, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$qtd un.',
                          style: TextStyle(
                            color: baixo ? c.vermelho : c.texto,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        if (baixo)
                          Text(
                            'Baixo',
                            style: TextStyle(
                              color: c.vermelho,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _IndicadorEstoque extends StatelessWidget {
  const _IndicadorEstoque({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.cor,
  });

  final String titulo;
  final String valor;
  final IconData icon;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
      decoration: BoxDecoration(
        gradient: c.gradCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cor.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: c.ehEscuro ? 0.06 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cor, size: 18),
          const SizedBox(height: 9),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.texto,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: c.textoSuave, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
