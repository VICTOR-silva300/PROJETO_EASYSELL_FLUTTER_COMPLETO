import 'package:flutter/material.dart';

import 'tema.dart';
import 'login_page.dart';
import 'sobre.dart' hide FundoLateral;
import 'ajuda_suporte.dart';
import 'fundo_lateral.dart';

class Opcoes extends StatefulWidget {
  final VoidCallback aoVoltar;

  const Opcoes({
    super.key,
    required this.aoVoltar,
  });

  @override
  State<Opcoes> createState() => _OpcoesState();
}

class _OpcoesState extends State<Opcoes> {
  bool notificacoes = true;
  bool sons = true;

  AppCores get c => context.cores;

  Color tom(Color cor, int alpha) => cor.withAlpha(alpha);

  @override
  Widget build(BuildContext context) {
    final c = this.c;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FundoLateral(
  child: Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(color: Colors.transparent),
    child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cabecalho(),

                const SizedBox(height: 24),


                const SizedBox(height: 28),

            

                _titulo(
                  'Preferências',
                  'Personalize a sua experiência',
                ),

                const SizedBox(height: 13),

                _opcaoSwitch(
                  icone: Icons.notifications_none_rounded,
                  titulo: 'Notificações',
                  descricao: 'Receber notificações do aplicativo',
                  cor: c.amarelo,
                  valor: notificacoes,
                  aoAlterar: (valor) {
                    setState(() {
                      notificacoes = valor;
                    });
                  },
                ),

                _opcaoSwitch(
                  icone: Icons.volume_up_outlined,
                  titulo: 'Sons',
                  descricao: 'Ativar sons do aplicativo',
                  cor: c.azul,
                  valor: sons,
                  aoAlterar: (valor) {
                    setState(() {
                      sons = valor;
                    });
                  },
                ),

                _opcaoSwitch(
                  icone: AppTema.escuro
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  titulo: 'Modo escuro',
                  descricao: AppTema.escuro
                      ? 'Tema escuro ativado'
                      : 'Tema claro ativado',
                  cor: c.roxoClaro,
                  valor: AppTema.escuro,
                  aoAlterar: (valor) {
                    AppTema.definirEscuro(valor);

                    setState(() {});
                  },
                ),

                const SizedBox(height: 18),

           

                _titulo(
                  'Aplicativo',
                  'Ajuda e informações',
                ),

                const SizedBox(height: 13),

                
                _opcao(
                  icone: Icons.help_outline_rounded,
                  titulo: 'Ajuda e suporte',
                  descricao: 'Encontre respostas e entre em contato',
                  cor: c.verde,
                  aoClicar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AjudaSuporte(),
                      ),
                    );
                  },
                ),

                
                _opcao(
                  icone: Icons.info_outline_rounded,
                  titulo: 'Sobre',
                  descricao: 'Informações sobre o EasySell',
                  cor: c.textoSuave,
                  aoClicar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Sobre(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),


                _titulo(
                  'Sessão',
                  'Encerre o acesso a esta conta',
                ),

                const SizedBox(height: 13),

                _sair(),

                const SizedBox(height: 28),

                Center(
                  child: Text(
                    'EasySell • Versão 1.0.0',
                    style: TextStyle(
                      color: c.textoFraco,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }


 Widget _cabecalho() {
  final c = this.c;

  return Row(
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.aoVoltar,
          mouseCursor: SystemMouseCursors.basic,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              gradient: c.gradCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: c.bordaMedia,
              ),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: c.texto,
              size: 21,
            ),
          ),
        ),
      ),

      const SizedBox(width: 12),

      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppCores.gradRoxo,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: c.roxo.withAlpha(65),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings_rounded,
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
              'CONFIGURAÇÕES',
              style: TextStyle(
                color: c.textoFraco,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Opções',
              style: TextStyle(
                color: c.texto,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget _titulo(
    String titulo,
    String subtitulo,
  ) {
    final c = this.c;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                c.roxoClaro,
                c.roxo,
              ],
            ),
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
                  color: c.texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitulo,
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: c.roxoClaro,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }



  Widget _iconeCaixa(
    IconData icone,
    Color cor,
  ) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: tom(cor, 30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tom(cor, 38),
        ),
      ),
      child: Icon(
        icone,
        color: cor,
        size: 20,
      ),
    );
  }



  Widget _textos(
    String titulo,
    String descricao,
  ) {
    final c = this.c;

    return Expanded(
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
            descricao,
            style: TextStyle(
              color: c.textoFraco,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }



  BoxDecoration _decoracaoCard() {
    final c = this.c;

    return BoxDecoration(
      gradient: c.gradCard,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(
        color: c.bordaSutil,
      ),
    );
  }


  Widget _opcao({
    required IconData icone,
    required String titulo,
    required String descricao,
    required Color cor,
    required VoidCallback aoClicar,
  }) {
    final c = this.c;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _decoracaoCard(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: aoClicar,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _iconeCaixa(
                  icone,
                  cor,
                ),

                const SizedBox(width: 14),

                _textos(
                  titulo,
                  descricao,
                ),

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



  Widget _opcaoSwitch({
    required IconData icone,
    required String titulo,
    required String descricao,
    required Color cor,
    required bool valor,
    required ValueChanged<bool> aoAlterar,
  }) {
    final c = this.c;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: _decoracaoCard(),
      child: Row(
        children: [
          _iconeCaixa(
            icone,
            cor,
          ),

          const SizedBox(width: 14),

          _textos(
            titulo,
            descricao,
          ),

          Switch(
            value: valor,
            onChanged: aoAlterar,
            thumbColor: WidgetStateProperty.resolveWith(
              (estados) {
                return estados.contains(WidgetState.selected)
                    ? Colors.white
                    : c.textoSuave;
              },
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (estados) {
                return estados.contains(WidgetState.selected)
                    ? c.roxo
                    : c.trilhaInativa;
              },
            ),
            trackOutlineColor:
                WidgetStateProperty.all(
              Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }



  Widget _sair() {
    final c = this.c;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tom(c.vermelho, 34),
            tom(c.vermelho, 10),
          ],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: tom(c.vermelho, 56),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: _confirmarSaida,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tom(c.vermelho, 32),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: tom(c.vermelho, 42),
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: c.vermelho,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sair da conta',
                        style: TextStyle(
                          color: c.vermelho,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Encerrar a sessão neste dispositivo',
                        style: TextStyle(
                          color: c.textoFraco,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: c.vermelho,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  void _confirmarSaida() {
    final c = this.c;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 26),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: c.gradSheet,
              borderRadius: BorderRadius.circular(27),
              border: Border.all(
                color: c.bordaMedia,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: tom(c.vermelho, 32),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: tom(c.vermelho, 42),
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: c.vermelho,
                    size: 26,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Sair da conta?',
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Você precisará entrar novamente para acessar sua conta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textoSuave,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.textoSuave,
                          side: BorderSide(
                            color: c.bordaMedia,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          
                          Navigator.pop(dialogContext);

                         
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.vermelho,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Sair',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

