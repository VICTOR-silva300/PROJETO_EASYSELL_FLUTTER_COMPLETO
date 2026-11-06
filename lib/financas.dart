import 'package:flutter/material.dart';

import 'api_service.dart';
import 'tema.dart';

/// Financeiro baseado nas vendas (clientes) da API, como no web.
class FinancasPage extends StatefulWidget {
  const FinancasPage({super.key});

  @override
  State<FinancasPage> createState() => _FinancasPageState();
}

class _FinancasPageState extends State<FinancasPage> {
  bool _loading = true;
  String? _erro;
  List<Map<String, dynamic>> _vendas = [];

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
      final lista = await ApiService.vendas();
      if (!mounted) return;
      setState(() {
        _vendas = lista;
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

  double _valor(Map<String, dynamic> v) {
    final raw = v['Preco_gasto'] ?? v['preco'] ?? v['valor'] ?? 0;
    if (raw is num) return raw.toDouble();
    return double.tryParse('$raw'.replaceAll(',', '.')) ?? 0;
  }

  String _cliente(Map<String, dynamic> v) =>
      (v['name'] ?? v['cliente'] ?? 'Cliente').toString();

  String _status(Map<String, dynamic> v) =>
      (v['status'] ?? 'registrada').toString();

  bool _concluida(Map<String, dynamic> venda) {
    final status = _status(venda).toLowerCase();
    return status == 'concluída' ||
        status == 'concluida' ||
        status == 'completed' ||
        status == 'finalizada';
  }

  String _money(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final vendasConcluidas = _vendas.where(_concluida).toList();
    final total = vendasConcluidas.fold<double>(
      0,
      (soma, venda) => soma + _valor(venda),
    );
    final concluidas = vendasConcluidas.length;
    final ticketMedio = concluidas == 0 ? 0.0 : total / concluidas;

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
              borderRadius: BorderRadius.circular(25),
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
                    Icons.account_balance_wallet_rounded,
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
                        'GESTÃO FINANCEIRA',
                        style: TextStyle(
                          color: c.textoFraco,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Financeiro',
                        style: TextStyle(
                          color: c.texto,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Receitas e movimentações da empresa',
                        style: TextStyle(color: c.textoSuave, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar financeiro',
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
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: AppCores.gradRoxo,
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: c.roxo.withValues(alpha: 0.17),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RECEITA CONFIRMADA',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _money(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calculada somente com vendas concluídas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_erro != null)
            _FinanceiroErro(mensagem: _erro!, onRetry: _carregar)
          else ...[
            Row(
              children: [
                Expanded(
                  child: _FinCard(
                    titulo: 'Vendas',
                    valor: '${_vendas.length}',
                    icon: Icons.point_of_sale_rounded,
                    cor: c.roxo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinCard(
                    titulo: 'Concluídas',
                    valor: '$concluidas',
                    icon: Icons.check_circle_rounded,
                    cor: c.verde,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FinCard(
              titulo: 'Ticket médio',
              valor: _money(ticketMedio),
              icon: Icons.analytics_outlined,
              cor: c.azul,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Movimentações',
                    style: TextStyle(
                      color: c.texto,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  '${_vendas.length} registros',
                  style: TextStyle(color: c.textoSuave, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Últimas vendas registradas',
              style: TextStyle(color: c.textoSuave, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (_vendas.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: c.gradCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.bordaSutil),
                ),
                child: Text(
                  'Nenhuma venda registrada ainda.',
                  style: TextStyle(color: c.textoSuave),
                ),
              )
            else
              ..._vendas.take(30).map((v) {
                final st = _status(v);
                final concluida = _concluida(v);
                final corStatus = concluida
                    ? c.verde
                    : st.toLowerCase().contains('cancel')
                    ? c.vermelho
                    : c.amarelo;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: c.gradCard,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: c.bordaSutil),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
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
                          color: corStatus.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          concluida
                              ? Icons.south_west_rounded
                              : Icons.receipt_long_outlined,
                          color: corStatus,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cliente(v),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.texto,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: corStatus.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                st,
                                style: TextStyle(
                                  color: corStatus,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _money(_valor(v)),
                        style: TextStyle(
                          color: concluida ? c.verde : c.texto,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

class _FinCard extends StatelessWidget {
  const _FinCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: c.gradCard,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: cor.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: c.ehEscuro ? 0.07 : 0.035),
            blurRadius: 15,
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
              color: cor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cor),
          ),
          const SizedBox(width: 12),
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
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
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

class _FinanceiroErro extends StatelessWidget {
  const _FinanceiroErro({required this.mensagem, required this.onRetry});

  final String mensagem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
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
            child: Text(mensagem, style: TextStyle(color: c.texto)),
          ),
          IconButton(
            tooltip: 'Tentar novamente',
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, color: c.roxo),
          ),
        ],
      ),
    );
  }
}
