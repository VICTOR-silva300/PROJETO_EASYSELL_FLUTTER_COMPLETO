import 'package:flutter/material.dart';
import 'fundo_lateral.dart';
import 'tema.dart';

class AjudaSuporte extends StatefulWidget {
  const AjudaSuporte({super.key});

  @override
  State<AjudaSuporte> createState() => _AjudaSuporteState();
}

class _AjudaSuporteState extends State<AjudaSuporte> {
  AppCores get c => context.cores;

  final TextEditingController mensagemController =
      TextEditingController();

  @override
  void dispose() {
    mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _cabecalho(),
                const SizedBox(height: 25),

                _boasVindas(),
                const SizedBox(height: 28),

                _titulo(
                  'Perguntas frequentes',
                  'Encontre respostas rápidas',
                ),
                const SizedBox(height: 13),

                _pergunta(
                  'Como cadastrar um produto?',
                  'Acesse a tela Produtos e toque no botão de adicionar. '
                      'Preencha as informações do produto e salve.',
                ),

                _pergunta(
                  'Como registrar uma venda?',
                  'Acesse a tela Vendas, escolha os produtos e informe '
                      'os dados necessários para registrar a venda.',
                ),

                _pergunta(
                  'Como adicionar um funcionário?',
                  'Acesse a tela Equipe e utilize a opção de adicionar '
                      'funcionário para cadastrar um novo membro.',
                ),

                _pergunta(
                  'Como alterar o tema do aplicativo?',
                  'Acesse Opções e ative ou desative a opção Modo escuro '
                      'para alternar entre os temas.',
                ),

                _pergunta(
                  'Meus dados ficam salvos?',
                  'Os dados cadastrados pelo aplicativo são utilizados '
                      'para organizar e controlar as informações do seu negócio.',
                ),

                const SizedBox(height: 28),

                _titulo(
                  'Enviar mensagem',
                  'Conte sua dúvida ou descreva o problema',
                ),
                const SizedBox(height: 13),

                _campoMensagem(),
                const SizedBox(height: 14),

                _botaoEnviar(),
                const SizedBox(height: 28),

                Center(
                  child: Column(
                    children: [
                      Text(
                        'EasySell',
                        style: TextStyle(
                          color: c.textoFraco,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Estamos aqui para ajudar.',
                        style: TextStyle(
                          color: c.textoFraco,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: c.superficie,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: c.bordaSutil),
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
            gradient: LinearGradient(
              colors: [c.azul, c.azul.withAlpha(170)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: c.azul.withAlpha(55),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CENTRAL DE AJUDA',
                style: TextStyle(
                  color: c.textoFraco,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ajuda e suporte',
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

  Widget _boasVindas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: c.gradDestaque,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: c.bordaMedia),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: c.azul.withAlpha(30),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: c.azul.withAlpha(45)),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: c.azul,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá! Como podemos ajudar?',
                  style: TextStyle(
                    color: c.texto,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Encontre respostas ou envie sua dúvida pelo formulário.',
                  style: TextStyle(
                    color: c.textoSuave,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String titulo, String subtitulo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.roxoClaro, c.roxo],
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

  Widget _pergunta(String pergunta, String resposta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: c.gradCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.bordaSutil),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 3,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
          iconColor: c.roxoClaro,
          collapsedIconColor: c.textoFraco,
          title: Text(
            pergunta,
            style: TextStyle(
              color: c.texto,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                resposta,
                style: TextStyle(
                  color: c.textoSuave,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoMensagem() {
    return TextField(
      controller: mensagemController,
      maxLines: 5,
      style: TextStyle(
        color: c.texto,
        fontSize: 12,
      ),
      cursorColor: c.roxoClaro,
      decoration: InputDecoration(
        hintText: 'Digite sua dúvida ou descreva o problema...',
        hintStyle: TextStyle(
          color: c.textoFraco,
          fontSize: 11,
        ),
        filled: true,
        fillColor: c.superficie,
        contentPadding: const EdgeInsets.all(15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c.bordaSutil),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: c.roxoClaro.withAlpha(180),
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _botaoEnviar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppCores.gradRoxo,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: c.roxo.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _enviarMensagem,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, size: 17),
              SizedBox(width: 8),
              Text(
                'Enviar mensagem',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _enviarMensagem() {
    final mensagem = mensagemController.text.trim();

    if (mensagem.isEmpty) {
      _mensagem('Digite uma mensagem antes de enviar.');
      return;
    }

    // Neste momento, a mensagem é validada localmente.
    // Para enviá-la de verdade, será necessário integrar uma API ou serviço.
    _mensagem('Mensagem validada. O envio ao suporte ainda precisa ser integrado.');
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            texto,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF181F31),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}