import 'package:flutter/material.dart';

import 'api_service.dart';
import 'tema.dart';

class ResumoPage extends StatefulWidget {
  const ResumoPage({super.key});

  @override
  State<ResumoPage> createState() => _ResumoPageState();
}

class _ResumoPageState extends State<ResumoPage> {
  bool _loading = true;
  String? _erro;
  int _produtos = 0;
  int _vendas = 0;
  int _equipe = 0;
  double _receita = 0;
  int _estoqueBaixo = 0;

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
      final results = await Future.wait([
        ApiService.produtos(),
        ApiService.vendas(),
        ApiService.funcionarios(),
      ]);
      final produtos = results[0];
      final vendas = results[1];
      final equipe = results[2];

      double receita = 0;
      for (final v in vendas) {
        final raw = v['Preco_gasto'] ?? v['preco'] ?? v['valor'] ?? 0;
        receita += (raw is num) ? raw.toDouble() : double.tryParse('$raw') ?? 0;
      }

      int baixo = 0;
      for (final p in produtos) {
        final q = p['quantidade'] ?? p['stock'] ?? p['qtd'] ?? 0;
        final n = (q is num) ? q.toInt() : int.tryParse('$q') ?? 0;
        if (n <= 10) baixo++;
      }

      if (!mounted) return;
      setState(() {
        _produtos = produtos.length;
        _vendas = vendas.length;
        _equipe = equipe.length;
        _receita = receita;
        _estoqueBaixo = baixo;
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

  String _money(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _carregar,
      color: c.roxo,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: c.gradDestaque,
              borderRadius: BorderRadius.circular(24),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppCores.gradRoxo,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.space_dashboard_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAINEL PRINCIPAL',
                        style: TextStyle(
                          color: c.textoFraco,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Resumo',
                        style: TextStyle(
                          color: c.texto,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Visão geral da sua operação',
                        style: TextStyle(color: c.textoSuave, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar resumo',
                  onPressed: _carregar,
                  icon: Icon(Icons.refresh_rounded, color: c.roxo),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_erro != null)
            _ErroCard(mensagem: _erro!, onRetry: _carregar)
          else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indicadores',
                        style: TextStyle(
                          color: c.texto,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Acompanhe os principais números da empresa',
                        style: TextStyle(color: c.textoSuave, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: c.verde.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.verde.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: c.verde),
                      const SizedBox(width: 6),
                      Text(
                        'ATUALIZADO',
                        style: TextStyle(
                          color: c.verde,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 1000 ? 4 : 2;
                final spacing = 12.0;
                final cards = [
                  _StatCard(
                    titulo: 'Receita',
                    valor: _money(_receita),
                    icon: Icons.attach_money_rounded,
                    cor: c.verde,
                  ),
                  _StatCard(
                    titulo: 'Vendas',
                    valor: '$_vendas',
                    icon: Icons.point_of_sale_rounded,
                    cor: c.roxo,
                  ),
                  _StatCard(
                    titulo: 'Produtos',
                    valor: '$_produtos',
                    icon: Icons.inventory_2_outlined,
                    cor: c.azul,
                  ),
                  _StatCard(
                    titulo: 'Equipe',
                    valor: '$_equipe',
                    icon: Icons.groups_outlined,
                    cor: c.amarelo,
                  ),
                ];
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width:
                              (constraints.maxWidth - spacing * (columns - 1)) /
                              columns,
                          child: card,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: c.gradCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (_estoqueBaixo > 0 ? c.vermelho : c.verde).withValues(
                    alpha: 0.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_estoqueBaixo > 0 ? c.vermelho : c.verde)
                        .withValues(alpha: c.ehEscuro ? 0.07 : 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (_estoqueBaixo > 0 ? c.vermelho : c.verde)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _estoqueBaixo > 0
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: _estoqueBaixo > 0 ? c.vermelho : c.verde,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _estoqueBaixo > 0
                              ? 'Atenção ao estoque'
                              : 'Estoque em dia',
                          style: TextStyle(
                            color: c.texto,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _estoqueBaixo > 0
                              ? '$_estoqueBaixo produto(s) com 10 ou menos unidades'
                              : 'Nenhum produto abaixo do limite de 10 unidades',
                          style: TextStyle(color: c.textoSuave, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: c.gradCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: c.ehEscuro ? 0.08 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: cor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: c.textoSuave, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErroCard extends StatelessWidget {
  const _ErroCard({required this.mensagem, required this.onRetry});

  final String mensagem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.vermelho.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.vermelho.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: c.vermelho, size: 36),
          const SizedBox(height: 10),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.texto, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
