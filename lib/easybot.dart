import 'package:flutter/material.dart';

import 'tema.dart';

/// EasyBot — chat local de assistência (UI alinhada ao web).
/// A IA completa depende do backend; aqui oferecemos interface + respostas úteis.
class EasyBotPage extends StatefulWidget {
  const EasyBotPage({super.key});

  @override
  State<EasyBotPage> createState() => _EasyBotPageState();
}

class _EasyBotPageState extends State<EasyBotPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg(
      bot: true,
      text:
          'Olá! Sou o EasyBot. Posso ajudar com dúvidas sobre produtos, estoque, vendas e equipe. '
          'Em breve a integração completa com a IA do backend estará disponível.',
    ),
  ];

  AppCores get c => context.cores;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _enviar() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(bot: false, text: text));
      _ctrl.clear();
    });
    _scrollToEnd();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(bot: true, text: _resposta(text)));
      });
      _scrollToEnd();
    });
  }

  String _resposta(String q) {
    final t = q.toLowerCase();
    if (t.contains('estoque') || t.contains('produto')) {
      return 'Para ver o estoque, abra a seção Estoque no menu. Produtos com 10 ou menos unidades ficam em alerta. '
          'Você pode editar quantidades na tela de Produtos.';
    }
    if (t.contains('venda') || t.contains('cliente')) {
      return 'As vendas ficam em Vendas (menu Gestão). Lá você registra clientes, valores e status dos pedidos.';
    }
    if (t.contains('equipe') || t.contains('funcionário')) {
      return 'Em Equipe você cadastra funcionários, define função e status. Use o menu Organização → Equipe.';
    }
    if (t.contains('financeiro') || t.contains('receita')) {
      return 'O Financeiro consolida as vendas registradas. Acesse Gestão → Financeiro para ver a receita total.';
    }
    if (t.contains('empresa')) {
      return 'Os dados da empresa ficam em Organização → Empresa. Lá você visualiza e atualiza o nome cadastrado.';
    }
    return 'Entendi. Navegue pelo menu lateral (ou gaveta no celular) para acessar Resumo, Produtos, Estoque, '
        'Vendas, Financeiro, Equipe, Empresa, Sell IA e Configurações. Em breve responderei com dados ao vivo da API.';
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppCores.gradRoxo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EasyBot',
                      style: TextStyle(
                        color: c.texto,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Assistente da operação',
                      style: TextStyle(color: c.textoSuave, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            itemCount: _msgs.length,
            itemBuilder: (context, i) {
              final m = _msgs[i];
              return Align(
                alignment: m.bot ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: m.bot ? c.superficie : c.roxo,
                    borderRadius: BorderRadius.circular(16),
                    border: m.bot ? Border.all(color: c.bordaSutil) : null,
                  ),
                  child: Text(
                    m.text,
                    style: TextStyle(
                      color: m.bot ? c.texto : Colors.white,
                      height: 1.35,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _enviar(),
                    decoration: InputDecoration(
                      hintText: 'Pergunte algo...',
                      filled: true,
                      fillColor: c.superficie,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: c.bordaSutil),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _enviar,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.roxo,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Msg {
  _Msg({required this.bot, required this.text});
  final bool bot;
  final String text;
}
