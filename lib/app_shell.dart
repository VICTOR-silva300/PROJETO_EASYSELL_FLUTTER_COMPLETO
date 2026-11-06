import 'dart:async';

import 'package:flutter/material.dart';

import 'tema.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'resumo.dart';
import 'home.dart';
import 'produtos.dart';
import 'estoque.dart';
import 'vendas.dart';
import 'financas.dart';
import 'equipe.dart';
import 'empresa.dart';
import 'sell_ia.dart';
import 'easybot.dart';
import 'configuracoes.dart';
import 'perfil.dart';
import 'profile_photo.dart';

/// Shell principal alinhado às seções do web (AppLayout).
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 1});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _index;

  static const _items = <_NavItem>[
    // Geral
    _NavItem(
      section: 'Geral',
      label: 'Resumo',
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
    ),
    _NavItem(
      section: 'Geral',
      label: 'Início',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    // Gestão
    _NavItem(
      section: 'Gestão',
      label: 'Produtos',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    _NavItem(
      section: 'Gestão',
      label: 'Estoque',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    _NavItem(
      section: 'Gestão',
      label: 'Vendas',
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale_rounded,
    ),
    _NavItem(
      section: 'Gestão',
      label: 'Financeiro',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
    ),
    // Organização
    _NavItem(
      section: 'Organização',
      label: 'Equipe',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
    ),
    _NavItem(
      section: 'Organização',
      label: 'Empresa',
      icon: Icons.business_outlined,
      activeIcon: Icons.business_rounded,
    ),
    // Inteligência
    _NavItem(
      section: 'Inteligência',
      label: 'Sell IA',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
    ),
    _NavItem(
      section: 'Inteligência',
      label: 'EasyBot',
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy_rounded,
    ),
    // Conta
    _NavItem(
      section: 'Conta',
      label: 'Configurações',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _items.length - 1);
    unawaited(
      ProfilePhoto.load().catchError((Object error) {
        debugPrint('Não foi possível carregar a foto do perfil: $error');
      }),
    );
  }

  AppCores get c => context.cores;

  Widget _pageFor(int i) {
    switch (i) {
      case 0:
        return const ResumoPage();
      case 1:
        return const DashboardHomeEmbedded();
      case 2:
        return const Produtos();
      case 3:
        return const EstoquePage();
      case 4:
        return const Vendas();
      case 5:
        return const FinancasPage();
      case 6:
        return const Equipe();
      case 7:
        return const EmpresaPage();
      case 8:
        return const SellIA();
      case 9:
        return const EasyBotPage();
      case 10:
        return const ConfiguracoesPage();
      case 11:
        return Perfil(aoVoltar: () => _go(1));
      default:
        return const ResumoPage();
    }
  }

  void _go(int i) {
    if (_index == i) return;
    setState(() => _index = i);
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _logout() async {
    ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 900;

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(_index), child: _pageFor(_index)),
    );

    if (useRail) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            _SideNav(
              items: _items,
              index: _index,
              onSelect: _go,
              onLogout: _logout,
              onProfile: () => _go(11),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: c.superficie.withValues(alpha: 0.96),
                      border: Border(bottom: BorderSide(color: c.bordaSutil)),
                    ),
                    child: Row(children: [const Spacer(), _botaoPerfil()]),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: c.superficie.withValues(alpha: 0.96),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14, top: 10, bottom: 10),
          child: Builder(
            builder: (context) => Material(
              color: c.fundo2,
              borderRadius: BorderRadius.circular(15),
              child: Tooltip(
                message: 'Abrir menu',
                waitDuration: const Duration(milliseconds: 550),
                preferBelow: false,
                decoration: BoxDecoration(
                  color: c.superficie,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.bordaMedia),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                textStyle: TextStyle(
                  color: c.texto,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                child: InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  borderRadius: BorderRadius.circular(15),
                  hoverColor: c.roxo.withValues(alpha: 0.1),
                  splashColor: c.roxo.withValues(alpha: 0.16),
                  highlightColor: c.roxo.withValues(alpha: 0.08),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.menu_rounded, color: c.texto, size: 23),
                  ),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 8,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tituloAtual,
              style: TextStyle(
                color: c.texto,
                fontWeight: FontWeight.w900,
                fontSize: 19,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'EasySell  ·  $_secaoAtual',
              style: TextStyle(
                color: c.textoSuave,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _go(11),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppCores.gradRoxo,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: c.roxo.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FotoPerfil(
                    tamanho: 40,
                    raio: 14,
                    fallback: _iniciaisUsuario(),
                    tamanhoFonte: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: c.bordaSutil),
        ),
      ),
      drawer: Drawer(
        width: 320,
        backgroundColor: c.superficie,
        elevation: 16,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
        child: SafeArea(
          child: _DrawerContent(
            items: _items,
            index: _index,
            onSelect: _go,
            onLogout: _logout,
            onProfile: () => _go(11),
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: _MobileBottomNavigation(
        index: _index,
        onSelect: _go,
      ),
    );
  }

  String get _tituloAtual => _index == 11 ? 'Perfil' : _items[_index].label;

  String get _secaoAtual => _index == 11 ? 'Conta' : _items[_index].section;

  Widget _botaoPerfil() {
    return Tooltip(
      message: 'Abrir perfil',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _go(11),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.roxo.withValues(alpha: 0.24)),
              boxShadow: [
                BoxShadow(
                  color: c.roxo.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: FotoPerfil(tamanho: 38, fallback: _iniciaisUsuario()),
          ),
        ),
      ),
    );
  }

  String _iniciaisUsuario() {
    final nome = ApiService.usuario?['name']?.toString().trim() ?? '';
    if (nome.isEmpty) return 'E';
    final partes = nome.split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'
        .toUpperCase();
  }
}

String _primeiraInicial(dynamic nome) {
  final texto = nome?.toString().trim() ?? '';
  return texto.isEmpty ? 'E' : texto.substring(0, 1).toUpperCase();
}

class _MobileBottomNavigation extends StatelessWidget {
  const _MobileBottomNavigation({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _destinations = <_NavItem>[
    _NavItem(
      section: '',
      label: 'Início',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      section: '',
      label: 'Produtos',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    _NavItem(
      section: '',
      label: 'Vendas',
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale_rounded,
    ),
    _NavItem(
      section: '',
      label: 'Equipe',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
    ),
    _NavItem(
      section: '',
      label: 'Sell IA',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
    ),
  ];

  static const _pageIndexes = [1, 2, 4, 6, 8];

  @override
  Widget build(BuildContext context) {
    final c = context.cores;

    return Container(
      decoration: BoxDecoration(
        color: c.navBar,
        border: Border(top: BorderSide(color: c.bordaSutil)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Row(
            children: List.generate(_destinations.length, (destinationIndex) {
              final item = _destinations[destinationIndex];
              final pageIndex = _pageIndexes[destinationIndex];
              final selected = index == pageIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(pageIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: selected ? c.roxo.withValues(alpha: 0.1) : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? c.roxo.withValues(alpha: 0.24)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          size: 22,
                          color: selected ? c.roxo : c.textoSuave,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? c.texto : c.textoSuave,
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.section,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String section;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.items,
    required this.index,
    required this.onSelect,
    required this.onLogout,
    required this.onProfile,
  });

  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    String? lastSection;

    return Container(
      width: 278,
      decoration: BoxDecoration(
        gradient: c.gradFundo,
        border: Border(right: BorderSide(color: c.bordaSutil)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: c.gradDestaque,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.roxo.withValues(alpha: 0.16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppCores.gradRoxo,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: c.roxo.withValues(alpha: 0.24),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EasySell',
                          style: TextStyle(
                            color: c.texto,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'GESTÃO DO SEU NEGÓCIO',
                          style: TextStyle(
                            color: c.textoSuave,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final showHeader = item.section != lastSection;
                  lastSection = item.section;
                  final selected = i == index;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showHeader)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            10,
                            i == 0 ? 8 : 18,
                            10,
                            7,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: c.roxo.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.section.toUpperCase(),
                                style: TextStyle(
                                  color: c.textoFraco,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onSelect(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? c.roxo.withValues(alpha: 0.11)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? c.roxo.withValues(alpha: 0.22)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? c.roxo.withValues(alpha: 0.13)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Icon(
                                    selected ? item.activeIcon : item.icon,
                                    size: 19,
                                    color: selected ? c.roxo : c.textoSuave,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: selected ? c.texto : c.textoSuave,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: c.roxo,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onProfile,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.fundo2.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.bordaSutil),
                    ),
                    child: Row(
                      children: [
                        FotoPerfil(
                          tamanho: 38,
                          fallback: _primeiraInicial(
                            ApiService.usuario?['name'],
                          ),
                          tamanhoFonte: 13,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ApiService.usuario?['name']?.toString() ??
                                    'Minha conta',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: c.texto,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Abrir perfil',
                                style: TextStyle(
                                  color: c.textoSuave,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sair',
                          onPressed: onLogout,
                          icon: Icon(
                            Icons.logout_rounded,
                            color: c.vermelho,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerContent extends StatelessWidget {
  const _DrawerContent({
    required this.items,
    required this.index,
    required this.onSelect,
    required this.onLogout,
    required this.onProfile,
  });

  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    String? lastSection;
    final nomeUsuario = ApiService.usuario?['name']?.toString().trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          decoration: BoxDecoration(
            gradient: c.gradDestaque,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: c.roxo.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppCores.gradRoxo,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: c.roxo.withValues(alpha: 0.24),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EasySell',
                      style: TextStyle(
                        color: c.texto,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'GESTÃO DO SEU NEGÓCIO',
                      style: TextStyle(
                        color: c.textoSuave,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Fechar menu',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: c.textoSuave,
                  backgroundColor: c.fundo2.withValues(alpha: 0.8),
                  fixedSize: const Size(38, 38),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final showHeader = item.section != lastSection;
              lastSection = item.section;
              final selected = i == index;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showHeader)
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, i == 0 ? 8 : 18, 10, 7),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 13,
                            decoration: BoxDecoration(
                              color: c.roxo.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.section.toUpperCase(),
                            style: TextStyle(
                              color: c.textoFraco,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelect(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? c.roxo.withValues(alpha: 0.11)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? c.roxo.withValues(alpha: 0.22)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: selected
                                    ? c.roxo.withValues(alpha: 0.13)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                selected ? item.activeIcon : item.icon,
                                size: 19,
                                color: selected ? c.roxo : c.textoSuave,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: selected ? c.texto : c.textoSuave,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (selected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: c.roxo,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onProfile,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.fundo2.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.bordaSutil),
                ),
                child: Row(
                  children: [
                    FotoPerfil(
                      tamanho: 38,
                      fallback: nomeUsuario != null && nomeUsuario.isNotEmpty
                          ? nomeUsuario.substring(0, 1).toUpperCase()
                          : 'E',
                      tamanhoFonte: 13,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomeUsuario?.isNotEmpty == true
                                ? nomeUsuario!
                                : 'Minha conta',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.texto,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Abrir perfil',
                            style: TextStyle(color: c.textoSuave, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.textoSuave),
                    IconButton(
                      tooltip: 'Sair',
                      onPressed: onLogout,
                      icon: Icon(
                        Icons.logout_rounded,
                        color: c.vermelho,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dashboard embutido no shell (reutiliza a lógica da Home sem o bottom nav antigo).
class DashboardHomeEmbedded extends StatelessWidget {
  const DashboardHomeEmbedded({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardHome(
      mudarTela: (_) {},
      abrirMenu: () {
        final scaffold = Scaffold.maybeOf(context);
        scaffold?.openDrawer();
      },
      abrirNotificacoes: () {},
    );
  }
}
