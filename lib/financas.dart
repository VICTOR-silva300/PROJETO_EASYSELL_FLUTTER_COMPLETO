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

  double _numero(dynamic valor) => valor is num
      ? valor.toDouble()
      : double.tryParse(valor?.toString().replaceAll(',', '.') ?? '') ?? 0;

  double _valor(Map<String, dynamic> venda) => _numero(venda['Preco_gasto']);

  String _cliente(Map<String, dynamic> v) =>
      (v['name'] ?? v['cliente'] ?? 'Cliente').toString();

  String _status(Map<String, dynamic> v) =>
      (v['status'] ?? 'Concluída').toString();

  bool _concluida(Map<String, dynamic> venda) => _status(venda) == 'Concluída';

  String? _dataVenda(Map<String, dynamic> venda) {
    final raw = venda['createdAt'] ?? venda['data'] ?? venda['created_at'];
    final data = DateTime.tryParse(raw?.toString() ?? '')?.toLocal();
    if (data == null) return null;
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} • '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }

  String _money(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final vendasConcluidas = _vendas.where(_concluida).toList();
    final total = vendasConcluidas.fold<double>(
      0,
      (soma, venda) => soma + _valor(venda),
    );
    final concluidas = vendasConcluidas.length;
    final ticketMedio = concluidas == 0 ? 0.0 : total / concluidas;
    final taxaConclusao = _vendas.isEmpty
        ? 0
        : (concluidas * 100 / _vendas.length).round();

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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: c.gradDestaque,
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: c.roxo.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: c.roxo.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumo financeiro',
                            style: TextStyle(
                              color: c.texto,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Receita das vendas concluídas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: c.textoFraco, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: c.verde.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: c.verde,
                        size: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _money(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Faturamento confirmado da empresa',
                  style: TextStyle(color: c.textoSuave, fontSize: 10),
                ),
                if (!_loading && _erro == null) ...[
                  const SizedBox(height: 19),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: c.roxo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (taxaConclusao / 100).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [c.roxo, c.roxoClaro],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$taxaConclusao% concluídas',
                        style: TextStyle(
                          color: c.roxoClaro,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(height: 1, color: c.bordaSutil),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _infoDestaque(
                        'Ticket médio',
                        _money(ticketMedio),
                        c.verde,
                        Icons.account_balance_wallet_outlined,
                      ),
                      _infoDestaque(
                        'Pedidos',
                        '${_vendas.length}',
                        c.azul,
                        Icons.receipt_long_outlined,
                      ),
                      _infoDestaque(
                        'Concluídas',
                        '$concluidas',
                        c.roxoClaro,
                        Icons.check_circle_outline_rounded,
                      ),
                    ],
                  ),
                ],
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
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c.roxo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: c.roxoClaro,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movimentações',
                        style: TextStyle(
                          color: c.texto,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Acompanhe suas vendas recentes',
                        style: TextStyle(color: c.textoSuave, fontSize: 10),
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
                    color: c.roxo.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.roxo.withValues(alpha: 0.12)),
                  ),
                  child: Text(
                    '${_vendas.length}',
                    style: TextStyle(
                      color: c.roxoClaro,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (_vendas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  gradient: c.gradCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: c.bordaSutil),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: c.roxo.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: c.roxoClaro,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'Nenhuma movimentação ainda',
                      style: TextStyle(
                        color: c.texto,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'As vendas registradas aparecerão aqui.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.textoSuave, fontSize: 11),
                    ),
                  ],
                ),
              )
            else
              ..._vendas.take(30).map(_movimentacaoCard),
          ],
        ],
      ),
    );
  }

  Widget _infoDestaque(String titulo, String valor, Color cor, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: cor, size: 13),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: c.textoFraco, fontSize: 9),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cor,
                    fontSize: 11,
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

  Widget _movimentacaoCard(Map<String, dynamic> venda) {
    final status = _status(venda);
    final concluida = _concluida(venda);
    final cancelada = status.toLowerCase().contains('cancel');
    final corStatus = concluida
        ? c.verde
        : cancelada
        ? c.vermelho
        : c.amarelo;
    final data = _dataVenda(venda);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: c.gradCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.bordaSutil),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.ehEscuro ? 0.07 : 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: corStatus.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              concluida
                  ? Icons.south_west_rounded
                  : cancelada
                  ? Icons.close_rounded
                  : Icons.schedule_rounded,
              color: corStatus,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cliente(venda),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: corStatus.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: corStatus,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (data != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          data,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: c.textoFraco, fontSize: 9),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(_valor(venda)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: concluida
                      ? c.verde
                      : cancelada
                      ? c.textoSuave
                      : c.texto,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'VALOR',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
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
