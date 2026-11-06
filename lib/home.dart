import 'package:flutter/material.dart';

import 'tema.dart';
import 'api_service.dart';
import 'produtos.dart';
import 'vendas.dart';
import 'equipe.dart';
import 'opcoes.dart';
import 'perfil.dart';
import 'sobre.dart';
import 'sell_ia.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int telaAtual = 0;

  AppCores get c => context.cores;

  void mudarTela(int index) {
    setState(() {
      telaAtual = index;
    });
  }

  Widget telaSelecionada() {
    switch (telaAtual) {
      case 1:
        return const Produtos();

      case 2:
        return const Vendas();

      case 3:
        return const Equipe();

      case 4:
        return const SellIA();

      case 6:
        return Sobre(aoVoltar: () => mudarTela(0));

      case 7:
        return Opcoes(aoVoltar: () => mudarTela(0));

      case 10:
        return Perfil(aoVoltar: () => mudarTela(0));

      default:
        return DashboardHome(
          mudarTela: mudarTela,
          abrirMenu: abrirMenu,
          abrirNotificacoes: abrirNotificacoes,
        );
    }
  }

  void abrirNotificacoes() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _PainelNotificacoes(),
    );
  }

  void abrirMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final cores = sheetContext.cores;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.86,
          ),
          decoration: BoxDecoration(
            gradient: cores.gradSheet,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cores.textoFraco,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Configurações EasySell',
                      style: TextStyle(
                        color: cores.texto,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Acesse outras ferramentas do aplicativo',
                      style: TextStyle(color: cores.textoSuave, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 21),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: cores.bordaSutil),
                  ),
                  _itemMenu(
                    cores: cores,
                    icon: Icons.person_outline_rounded,
                    titulo: 'Perfil',
                    subtitulo: 'Seus dados e informações',
                    cor: cores.roxoClaro,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      mudarTela(10);
                    },
                  ),
                  _itemMenu(
                    cores: cores,
                    icon: Icons.settings_outlined,
                    titulo: 'Opções',
                    subtitulo: 'Configurações do aplicativo',
                    cor: cores.amarelo,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      mudarTela(7);
                    },
                  ),
                  _itemMenu(
                    cores: cores,
                    icon: Icons.info_outline_rounded,
                    titulo: 'Sobre',
                    subtitulo: 'Conheça o EasySell',
                    cor: cores.textoSuave,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      mudarTela(6);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _itemMenu({
    required AppCores cores,
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color cor,
    required VoidCallback onTap,
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
              color: cores.fundo2,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: cores.bordaSutil),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cor.withAlpha(28),
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
                          color: cores.texto,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: TextStyle(color: cores.textoSuave, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: cores.textoFraco,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int bottomIndex = telaAtual <= 4 ? telaAtual : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(telaAtual), child: telaSelecionada()),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.navBar,
          border: Border(top: BorderSide(color: c.bordaSutil)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Início',
                  ativo: bottomIndex == 0,
                ),
                _bottomItem(
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2_rounded,
                  label: 'Produtos',
                  ativo: bottomIndex == 1,
                ),
                _bottomItem(
                  index: 2,
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long_rounded,
                  label: 'Vendas',
                  ativo: bottomIndex == 2,
                ),
                _bottomItem(
                  index: 3,
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups_rounded,
                  label: 'Equipe',
                  ativo: bottomIndex == 3,
                ),
                _bottomItem(
                  index: 4,
                  icon: Icons.auto_awesome_outlined,
                  selectedIcon: Icons.auto_awesome_rounded,
                  label: 'Sell IA',
                  ativo: bottomIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool ativo,
  }) {
    return GestureDetector(
      onTap: () => mudarTela(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          gradient: ativo
              ? LinearGradient(
                  colors: [c.roxo.withAlpha(50), c.roxo.withAlpha(24)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ativo ? c.roxo.withAlpha(53) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ativo ? selectedIcon : icon,
              color: ativo ? c.roxoClaro : c.textoSuave,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: ativo ? c.texto : c.textoSuave,
                fontSize: 9,
                fontWeight: ativo ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  final Function(int) mudarTela;
  final VoidCallback abrirMenu;
  final VoidCallback abrirNotificacoes;

  const DashboardHome({
    super.key,
    required this.mudarTela,
    required this.abrirMenu,
    required this.abrirNotificacoes,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  List<Map<String, dynamic>> _vendas = [];
  List<Map<String, dynamic>> _produtos = [];
  List<Map<String, dynamic>> _equipe = [];

  Function(int) get mudarTela => widget.mudarTela;
  VoidCallback get abrirMenu => widget.abrirMenu;
  VoidCallback get abrirNotificacoes => widget.abrirNotificacoes;

  List<double> get _vendasPorDia {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final inicio = hoje.subtract(
      Duration(days: hoje.weekday - DateTime.monday),
    );
    return List<double>.generate(7, (i) {
      final dia = inicio.add(Duration(days: i));
      return _vendas
          .where((v) {
            if (!_vendaConcluida(v)) return false;
            final data = _dataVenda(
              v['createdAt'] ?? v['data'] ?? v['dataVenda'],
            );
            return data != null &&
                data.year == dia.year &&
                data.month == dia.month &&
                data.day == dia.day;
          })
          .length
          .toDouble();
    });
  }

  List<String> get _diasSemana => const [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  String get _nomeUsuario {
    final nome = ApiService.usuario?['name']?.toString().trim();

    if (nome != null && nome.isNotEmpty) {
      return nome;
    }

    return 'Administrador';
  }

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    try {
      final dados = await Future.wait([
        ApiService.vendas(),
        ApiService.produtos(),
        ApiService.funcionarios(),
      ]);

      if (!mounted) return;

      setState(() {
        _vendas = dados[0];
        _produtos = dados[1];
        _equipe = dados[2];
      });
    } catch (_) {}
  }

  double _numero(dynamic valor) {
    return valor is num
        ? valor.toDouble()
        : double.tryParse(valor?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  bool _vendaConcluida(Map<String, dynamic> venda) {
    final status = (venda['status']?.toString() ?? 'Concluída')
        .trim()
        .toLowerCase();
    return status.isEmpty ||
        status == 'concluída' ||
        status == 'concluida' ||
        status == 'concluído' ||
        status == 'concluido' ||
        status == 'completed' ||
        status == 'finalizada' ||
        status == 'finalizado';
  }

  DateTime? _dataVenda(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString())?.toLocal();
  }

  bool _mesAtual(dynamic valor) {
    final data = _dataVenda(valor);
    final agora = DateTime.now();

    return data != null && data.year == agora.year && data.month == agora.month;
  }

  bool _diaAtual(dynamic valor) {
    final data = _dataVenda(valor);
    final agora = DateTime.now();

    return data != null &&
        data.year == agora.year &&
        data.month == agora.month &&
        data.day == agora.day;
  }

  bool _semanaAtual(dynamic valor) {
    final data = _dataVenda(valor);
    if (data == null) return false;

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    // A semana começa na segunda-feira e termina no domingo.
    final inicioSemana = hoje.subtract(
      Duration(days: hoje.weekday - DateTime.monday),
    );
    final inicioProximaSemana = inicioSemana.add(const Duration(days: 7));

    return !data.isBefore(inicioSemana) && data.isBefore(inicioProximaSemana);
  }

  double get _faturamentoTotal {
    return _vendas
        .where((v) => _vendaConcluida(v) && _mesAtual(v['createdAt']))
        .fold(0.0, (total, venda) => total + _numero(venda['Preco_gasto']));
  }

  double get _faturamentoHoje {
    return _vendas
        .where((v) => _vendaConcluida(v) && _diaAtual(v['createdAt']))
        .fold(0.0, (total, venda) => total + _numero(venda['Preco_gasto']));
  }

  double get _faturamentoSemana {
    return _vendas
        .where((v) => _vendaConcluida(v) && _semanaAtual(v['createdAt']))
        .fold(0.0, (total, venda) => total + _numero(venda['Preco_gasto']));
  }

  int get _vendasConcluidas {
    return _vendas.where(_vendaConcluida).length;
  }

  String get _mesAtualTexto {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    final agora = DateTime.now();
    return '${meses[agora.month - 1]} de ${agora.year}';
  }

  String _dinheiro(dynamic valor) {
    final n = _numero(valor);

    return 'R\$ ${n.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _cabecalho(cores),
                  const SizedBox(height: 27),
                  _mensagemBoasVindas(cores),
                  const SizedBox(height: 21),
                  _faturamento(cores),
                  const SizedBox(height: 22),
                  _indicadores(cores),
                  const SizedBox(height: 29),
                  _titulo(
                    cores,
                    'Desempenho',
                    'Acompanhe suas vendas durante a semana',
                  ),
                  const SizedBox(height: 13),
                  _graficoDesempenho(cores),
                  const SizedBox(height: 29),
                  _titulo(
                    cores,
                    'Vendas recentes',
                    'Últimas movimentações realizadas',
                  ),
                  const SizedBox(height: 13),
                  _vendasRecentes(cores),
                  const SizedBox(height: 22),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(AppCores cores) {
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
                color: cores.roxo.withAlpha(66),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PAINEL PRINCIPAL',
                style: TextStyle(
                  color: cores.textoFraco,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'EasySell',
                style: TextStyle(
                  color: cores.texto,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _botaoCabecalho(
          cores: cores,
          icon: Icons.notifications_rounded,
          onTap: abrirNotificacoes,
        ),
      ],
    );
  }

  Widget _botaoCabecalho({
    required AppCores cores,
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
              color: cores.superficie,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cores.bordaMedia),
            ),
            child: Icon(icon, color: cores.texto, size: 20),
          ),
          if (notificacao)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: cores.vermelho,
                  shape: BoxShape.circle,
                  border: Border.all(color: cores.superficie, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _mensagemBoasVindas(AppCores cores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bom dia, $_nomeUsuario 👋',
                style: TextStyle(
                  color: cores.texto,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: cores.verde.withAlpha(24),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: cores.verde.withAlpha(38)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, color: cores.verde, size: 6),
                  const SizedBox(width: 5),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: cores.verde,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'Veja como está o seu negócio hoje.',
          style: TextStyle(color: cores.textoSuave, fontSize: 12),
        ),
        const SizedBox(height: 15),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cores.roxo, cores.roxoClaro]),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _faturamento(AppCores cores) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: cores.gradDestaque,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: cores.roxo.withAlpha(58)),
        boxShadow: [
          BoxShadow(
            color: cores.roxo.withAlpha(37),
            blurRadius: 30,
            offset: const Offset(0, 13),
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
                  gradient: AppCores.gradRoxo,
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
                      'Faturamento',
                      style: TextStyle(
                        color: cores.texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _mesAtualTexto,
                      style: TextStyle(color: cores.textoFraco, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            _dinheiro(_faturamentoTotal),
            style: TextStyle(
              color: cores.texto,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Total faturado neste mês',
            style: TextStyle(color: cores.textoSuave, fontSize: 10),
          ),
          const SizedBox(height: 19),
          Container(height: 1, color: cores.bordaSutil),
          const SizedBox(height: 16),
          Row(
            children: [
              _faturamentoInfo(
                cores,
                'Hoje',
                _dinheiro(_faturamentoHoje),
                cores.verde,
                Icons.today_rounded,
              ),
              _faturamentoInfo(
                cores,
                'Esta semana',
                _dinheiro(_faturamentoSemana),
                cores.azul,
                Icons.date_range_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _faturamentoInfo(
    AppCores cores,
    String titulo,
    String valor,
    Color cor,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: cor.withAlpha(24),
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
                  style: TextStyle(color: cores.textoFraco, fontSize: 8),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cor,
                    fontSize: 10,
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

  Widget _indicadores(AppCores cores) {
    return Row(
      children: [
        Expanded(
          child: _indicador(
            cores: cores,
            icon: Icons.shopping_bag_outlined,
            titulo: 'Vendas',
            valor: '$_vendasConcluidas',
            detalhe: 'TOTAL',
            cor: cores.azul,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _indicador(
            cores: cores,
            icon: Icons.inventory_2_outlined,
            titulo: 'Produtos',
            valor: '${_produtos.length}',
            detalhe: 'TOTAL',
            cor: cores.roxoClaro,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _indicador(
            cores: cores,
            icon: Icons.groups_outlined,
            titulo: 'Equipe',
            valor: '${_equipe.length}',
            detalhe: 'TOTAL',
            cor: cores.verde,
          ),
        ),
      ],
    );
  }

  Widget _indicador({
    required AppCores cores,
    required IconData icon,
    required String titulo,
    required String valor,
    required String detalhe,
    required Color cor,
  }) {
    return Container(
      height: 133,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: cores.gradCard,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: cores.bordaSutil),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: cor.withAlpha(27),
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
              color: cores.texto,
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
                  style: TextStyle(color: cores.textoSuave, fontSize: 9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withAlpha(25),
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

  Widget _titulo(AppCores cores, String titulo, String subtitulo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cores.roxoClaro, cores.roxo]),
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
                  color: cores.texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: TextStyle(color: cores.textoFraco, fontSize: 10),
              ),
            ],
          ),
        ),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: cores.roxoClaro,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _graficoDesempenho(AppCores cores) {
    return Container(
      height: 270,
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 14),
      decoration: BoxDecoration(
        gradient: cores.gradCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cores.bordaSutil),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cores.roxo.withAlpha(31),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: cores.roxoClaro,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendas da semana',
                    style: TextStyle(
                      color: cores.texto,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Vendas concluídas registradas por dia',
                    style: TextStyle(color: cores.textoFraco, fontSize: 8),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: cores.roxo.withAlpha(24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: cores.roxoClaro,
                      size: 10,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Semana',
                      style: TextStyle(
                        color: cores.roxoClaro,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomPaint(
                painter: _GraficoSemanalPainter(cores, _vendasPorDia),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              return _diaGrafico(
                cores,
                _diasSemana[index],
                ativo: index == DateTime.now().weekday - 1,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _diaGrafico(AppCores cores, String texto, {bool ativo = false}) {
    return Text(
      texto,
      style: TextStyle(
        color: ativo ? cores.roxoClaro : cores.textoFraco,
        fontSize: 8,
        fontWeight: ativo ? FontWeight.w900 : FontWeight.w500,
      ),
    );
  }

  Widget _vendasRecentes(AppCores cores) {
    final concluidas = _vendas.where(_vendaConcluida).toList()
      ..sort((a, b) {
        final dataA = _dataVenda(a['createdAt'] ?? a['data'] ?? a['dataVenda']);
        final dataB = _dataVenda(b['createdAt'] ?? b['data'] ?? b['dataVenda']);

        if (dataA == null && dataB == null) return 0;
        if (dataA == null) return 1;
        if (dataB == null) return -1;

        return dataB.compareTo(dataA);
      });

    if (concluidas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: cores.gradCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cores.bordaSutil),
        ),
        child: Center(
          child: Text(
            'Nenhuma venda cadastrada ainda.',
            style: TextStyle(color: cores.textoSuave, fontSize: 12),
          ),
        ),
      );
    }

    final recentes = concluidas.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: cores.gradCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cores.bordaSutil),
      ),
      child: Column(
        children: [
          for (int i = 0; i < recentes.length; i++) ...[
            _venda(
              cores: cores,
              numero:
                  '#${recentes[i]['Numero'] ?? recentes[i]['_id'] ?? 'Venda'}',
              produto: 'Venda',
              cliente: recentes[i]['name']?.toString() ?? 'Cliente',
              valor: _dinheiro(recentes[i]['Preco_gasto']),
              tempo:
                  recentes[i]['createdAt']?.toString().split('T').first ??
                  'Agora',
              cor: _vendaConcluida(recentes[i]) ? cores.verde : cores.amarelo,
              icon: Icons.shopping_bag_outlined,
            ),
            if (i < recentes.length - 1) _divisor(cores),
          ],
        ],
      ),
    );
  }

  Widget _venda({
    required AppCores cores,
    required String numero,
    required String produto,
    required String cliente,
    required String valor,
    required String tempo,
    required Color cor,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cor.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cor.withAlpha(38)),
            ),
            child: Icon(icon, color: cor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cores.texto,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$numero • $cliente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cores.textoFraco, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: TextStyle(
                  color: cores.texto,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: cores.texto.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tempo,
                  style: TextStyle(
                    color: cores.textoFraco,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divisor(AppCores cores) {
    return Padding(
      padding: const EdgeInsets.only(left: 73),
      child: Divider(color: cores.bordaSutil, height: 1),
    );
  }
}

class _GraficoSemanalPainter extends CustomPainter {
  final AppCores cores;
  final List<double> valores;

  _GraficoSemanalPainter(this.cores, this.valores);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || valores.isEmpty) return;

    final largura = size.width / valores.length;
    final maximo = valores.fold<double>(0, (a, b) => a > b ? a : b);

    final grade = Paint()
      ..color = cores.bordaSutil
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grade);
    }

    for (int i = 0; i < valores.length; i++) {
      final x = largura * i + largura / 2;
      final proporcao = maximo <= 0
          ? 0.025
          : (valores[i] / maximo).clamp(0.025, 1.0);
      final altura = (size.height * 0.88 * proporcao).toDouble();
      final topo = size.height - altura;
      final rect = Rect.fromLTWH(x - 11, topo, 22, altura);

      final sombra = Paint()
        ..color = cores.roxo.withAlpha(30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        sombra,
      );

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cores.roxoClaro, cores.roxo, cores.roxo.withAlpha(190)],
        ).createShader(rect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );

      if (maximo > 0 && valores[i] == maximo) {
        canvas.drawCircle(Offset(x, topo), 3, Paint()..color = cores.verde);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GraficoSemanalPainter oldDelegate) {
    if (oldDelegate.cores != cores ||
        oldDelegate.valores.length != valores.length) {
      return true;
    }
    for (int i = 0; i < valores.length; i++) {
      if (oldDelegate.valores[i] != valores[i]) return true;
    }
    return false;
  }
}

class _PainelNotificacoes extends StatefulWidget {
  const _PainelNotificacoes();

  @override
  State<_PainelNotificacoes> createState() => _PainelNotificacoesState();
}

class _PainelNotificacoesState extends State<_PainelNotificacoes> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _carregarNotificacoes();
  }

  Future<List<Map<String, dynamic>>> _carregarNotificacoes() async {
    final resultados = await Future.wait<dynamic>([
      ApiService.produtos(),
      ApiService.vendas(),
    ]);

    final produtos = List<Map<String, dynamic>>.from(resultados[0] as List);
    final vendas = List<Map<String, dynamic>>.from(resultados[1] as List);
    final notificacoes = <Map<String, dynamic>>[];

    for (final produto in produtos) {
      final quantidade = _numero(
        produto['quantidade'] ?? produto['Quantidade'] ?? produto['estoque'],
      );

      if (quantidade <= 5) {
        notificacoes.add({
          'titulo': quantidade <= 0 ? 'Produto sem estoque' : 'Estoque baixo',
          'descricao':
              '${produto['name'] ?? produto['nome'] ?? 'Produto'}: '
              '${quantidade.toInt()} unidade(s) disponível(is).',
          'icone': quantidade <= 0
              ? Icons.remove_shopping_cart_rounded
              : Icons.inventory_2_outlined,
          'cor': quantidade <= 0 ? Colors.redAccent : Colors.orangeAccent,
          'data': produto['updatedAt'] ?? produto['createdAt'],
          'ordem': _data(produto['updatedAt'] ?? produto['createdAt']),
        });
      }
    }

    vendas.sort((a, b) {
      final dataA = _data(a['createdAt']);
      final dataB = _data(b['createdAt']);
      if (dataA == null && dataB == null) return 0;
      if (dataA == null) return 1;
      if (dataB == null) return -1;
      return dataB.compareTo(dataA);
    });

    for (final venda in vendas.take(5)) {
      final status = venda['status']?.toString().toLowerCase() ?? '';
      if (status.contains('cancel')) continue;

      notificacoes.add({
        'titulo': 'Venda registrada',
        'descricao':
            '${venda['name'] ?? venda['cliente'] ?? 'Cliente'} • '
            '${_dinheiro(venda['Preco_gasto'] ?? venda['preco'])}',
        'icone': Icons.shopping_bag_outlined,
        'cor': Colors.greenAccent,
        'data': venda['createdAt'],
        'ordem': _data(venda['createdAt']),
      });
    }

    notificacoes.sort((a, b) {
      final dataA = a['ordem'] as DateTime?;
      final dataB = b['ordem'] as DateTime?;
      if (dataA == null && dataB == null) return 0;
      if (dataA == null) return 1;
      if (dataB == null) return -1;
      return dataB.compareTo(dataA);
    });

    return notificacoes;
  }

  DateTime? _data(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString())?.toLocal();
  }

  double _numero(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  String _dinheiro(dynamic valor) {
    return 'R\$ ${_numero(valor).toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _tempo(dynamic valor) {
    final data = _data(valor);
    if (data == null) return 'Data indisponível';

    final diferenca = DateTime.now().difference(data);
    if (diferenca.isNegative || diferenca.inMinutes < 1) return 'Agora';
    if (diferenca.inMinutes < 60) return 'Há ${diferenca.inMinutes} min';
    if (diferenca.inHours < 24) return 'Há ${diferenca.inHours} h';
    if (diferenca.inDays == 1) return 'Ontem';
    if (diferenca.inDays < 7) return 'Há ${diferenca.inDays} dias';

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        decoration: BoxDecoration(
          gradient: cores.gradSheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: cores.textoFraco,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppCores.gradRoxo,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notificações',
                            style: TextStyle(
                              color: cores.texto,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Atualizações do seu negócio',
                            style: TextStyle(
                              color: cores.textoSuave,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Atualizar notificações',
                      onPressed: () {
                        setState(() {
                          _future = _carregarNotificacoes();
                        });
                      },
                      icon: Icon(Icons.refresh_rounded, color: cores.roxoClaro),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: cores.roxoClaro,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _estado(
                        cores,
                        Icons.cloud_off_rounded,
                        'Não foi possível carregar',
                        'Verifique sua conexão e tente novamente.',
                        botao: true,
                      );
                    }

                    final notificacoes = snapshot.data ?? [];
                    if (notificacoes.isEmpty) {
                      return _estado(
                        cores,
                        Icons.notifications_none_rounded,
                        'Tudo em dia!',
                        'Não há vendas recentes ou produtos com estoque baixo.',
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 25),
                      itemCount: notificacoes.length,
                      itemBuilder: (context, index) {
                        final item = notificacoes[index];
                        final cor = item['cor'] as Color;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 11),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: cores.fundo2,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: cores.bordaSutil),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: cor.withAlpha(28),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  item['icone'] as IconData,
                                  color: cor,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['titulo'].toString(),
                                      style: TextStyle(
                                        color: cores.texto,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item['descricao'].toString(),
                                      style: TextStyle(
                                        color: cores.textoSuave,
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _tempo(item['data']),
                                      style: TextStyle(
                                        color: cores.textoFraco,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estado(
    AppCores cores,
    IconData icone,
    String titulo,
    String descricao, {
    bool botao = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cores.roxoClaro, size: 48),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cores.texto,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: TextStyle(color: cores.textoSuave, fontSize: 12),
            ),
            if (botao) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _future = _carregarNotificacoes();
                  });
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Decoração lateral reutilizável baseada no fundo da tela de login do EasySell.
/// Coloca os efeitos por cima do conteúdo sem bloquear toques.
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
