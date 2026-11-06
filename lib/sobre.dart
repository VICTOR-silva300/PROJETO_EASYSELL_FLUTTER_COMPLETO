import 'package:flutter/material.dart';

import 'tema.dart';

class Sobre extends StatelessWidget {
  final VoidCallback? aoVoltar;

  const Sobre({super.key, this.aoVoltar});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cabecalho(context, c),
                const SizedBox(height: 28),

                
                Center(child: _logo()),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'EasySell',
                    style: TextStyle(
                      color: c.texto,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Consultoria para pequenos negócios',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textoSuave, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 30),

                
                _titulo(c, 'Sobre a EASYSELL', 'Quem somos e o que fazemos'),
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: _decoracaoCard(c),
                  child: Text(
                    'A EASYSELL é uma empresa de consultoria focada em ajudar microempreendedores a crescerem de forma simples, prática e eficiente. Nosso objetivo é tornar a gestão do seu negócio mais fácil, oferecendo orientação estratégica, soluções inteligentes e suporte no dia a dia para melhorar vendas, organização e tomada de decisões.\n\n'
                    'Acreditamos que todo pequeno negócio tem potencial para se tornar grande quando recebe as ferramentas certas. Por isso, trabalhamos lado a lado com cada cliente, entendendo suas necessidades e propondo melhorias reais em áreas como vendas, atendimento, organização de processos e uso de tecnologia.\n\n'
                    'Mais do que consultoria, a EASYSELL é uma parceira de crescimento. Estamos aqui para simplificar o que parece complicado e ajudar você a vender mais, organizar melhor seu negócio e alcançar resultados consistentes.',
                    style: TextStyle(
                      color: c.textoSuave,
                      fontSize: 12,
                      height: 1.65,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                
                _titulo(c, 'Contatos', 'Fale com a gente'),
                const SizedBox(height: 13),
                _contato(
                  c,
                  icone: Icons.email_outlined,
                  titulo: 'E-mail',
                  valor: 'contato@easysell.com.br',
                  cor: c.azul,
                ),
                _contato(
                  c,
                  icone: Icons.phone_outlined,
                  titulo: 'Telefone',
                  valor: '(11) 99999-9999',
                  cor: c.verde,
                ),
                _contato(
                  c,
                  icone: Icons.location_on_outlined,
                  titulo: 'Localização',
                  valor: 'São Paulo - SP',
                  cor: c.amarelo,
                ),
                _contato(
                  c,
                  icone: Icons.language_rounded,
                  titulo: 'Site',
                  valor: 'www.easysell.com.br',
                  cor: c.roxoClaro,
                ),
                const SizedBox(height: 14),

                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: c.gradDestaque,
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(color: const Color(0x3A7C3AED)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x252563EB),
                        blurRadius: 30,
                        offset: Offset(0, 13),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppCores.gradRoxo,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          'Simplificando a gestão para ajudar seu negócio a crescer.',
                          style: TextStyle(
                            color: c.texto,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                Center(
                  child: Text(
                    'EasySell © 2026',
                    style: TextStyle(color: c.textoFraco, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoracaoCard(AppCores c, {double raio = 24}) {
    return BoxDecoration(
      gradient: c.gradCard,
      borderRadius: BorderRadius.circular(raio),
      border: Border.all(color: c.bordaSutil),
    );
  }

  Widget _cabecalho(BuildContext context, AppCores c) {
    return Row(
      children: [
        GestureDetector(
          onTap: aoVoltar ?? () => Navigator.maybePop(context),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.bordaMedia),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: c.texto,
              size: 18,
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
            boxShadow: const [
              BoxShadow(
                color: Color(0x422563EB),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.info_outline_rounded,
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
                'INSTITUCIONAL',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sobre',
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

  Widget _titulo(AppCores c, String titulo, String subtitulo) {
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

  Widget _logo() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        gradient: AppCores.gradRoxo,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x477C3AED),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
    );
  }

  Widget _contato(
    AppCores c, {
    required IconData icone,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: _decoracaoCard(c, raio: 21),
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
            child: Icon(icone, color: cor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: c.textoFraco, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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
            child: CustomPaint(
              painter: _FundoLateralPainter(),
            ),
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
