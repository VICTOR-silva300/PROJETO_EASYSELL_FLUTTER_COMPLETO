import 'package:flutter/material.dart';
import 'tema.dart';
import 'api_service.dart';

class SellIA extends StatefulWidget {
const SellIA({super.key});

@override
State<SellIA> createState() => _SellIAState();
}

class _SellIAState extends State<SellIA> {
AppCores get c => context.cores;

final TextEditingController mensagemController = TextEditingController();
final ScrollController scrollController = ScrollController();

final List<Map<String, dynamic>> mensagens = [
{
'tipo': 'ia',
'texto':
'Olá! Eu sou a Sell IA 👋\n\nPosso ajudar você a entender suas vendas, produtos, estoque e resultados do negócio.',
},
];

bool pensando = false;
bool carregandoDados = true;
bool erroCarregamento = false;

List<Map<String, dynamic>> vendasBanco = [];
List<Map<String, dynamic>> produtosBanco = [];
List<Map<String, dynamic>> funcionariosBanco = [];

@override
void initState() {
super.initState();
_carregarDados();
}

Future<void> _carregarDados() async {
try {
final dados = await Future.wait([
ApiService.vendas(),
ApiService.produtos(),
ApiService.funcionarios(),
]);


  if (!mounted) return;

  setState(() {
    vendasBanco = _converterLista(dados[0]);
    produtosBanco = _converterLista(dados[1]);
    funcionariosBanco = _converterLista(dados[2]);
    carregandoDados = false;
    erroCarregamento = false;
  });
} catch (e) {
  if (!mounted) return;

  setState(() {
    carregandoDados = false;
    erroCarregamento = true;
  });
}


}

List<Map<String, dynamic>> _converterLista(dynamic dados) {
if (dados is! List) return [];


return dados
    .whereType<Map>()
    .map((item) => Map<String, dynamic>.from(item))
    .toList();


}

String _normalizar(String texto) {
return texto
.toLowerCase()
.trim()
.replaceAll('á', 'a')
.replaceAll('à', 'a')
.replaceAll('ã', 'a')
.replaceAll('â', 'a')
.replaceAll('é', 'e')
.replaceAll('ê', 'e')
.replaceAll('í', 'i')
.replaceAll('ó', 'o')
.replaceAll('ô', 'o')
.replaceAll('õ', 'o')
.replaceAll('ú', 'u')
.replaceAll('ç', 'c');
}

double _numero(dynamic valor) {
if (valor is num) return valor.toDouble();


String texto = valor?.toString().trim() ?? '';

if (texto.isEmpty || texto == 'null') return 0;

texto = texto.replaceAll('R\$', '').replaceAll(' ', '');

if (texto.contains(',') && texto.contains('.')) {
  if (texto.lastIndexOf(',') > texto.lastIndexOf('.')) {
    texto = texto.replaceAll('.', '').replaceAll(',', '.');
  } else {
    texto = texto.replaceAll(',', '');
  }
} else if (texto.contains(',')) {
  texto = texto.replaceAll(',', '.');
}

return double.tryParse(texto) ?? 0;


}

String? _textoCampo(
Map<String, dynamic> dados,
List<String> campos,
) {
for (final campo in campos) {
final valor = dados[campo];


  if (valor == null) continue;

  if (valor is Map) {
    final nome = valor['name'] ??
        valor['nome'] ??
        valor['Nome'] ??
        valor['nomeProduto'] ??
        valor['produto'] ??
        valor['descricao'];

    if (nome != null &&
        nome.toString().trim().isNotEmpty &&
        nome.toString() != 'null') {
      return nome.toString().trim();
    }

    final id = valor['_id'] ?? valor['id'];

    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString().trim();
    }
  }

  final texto = valor.toString().trim();

  if (texto.isNotEmpty && texto != 'null') {
    return texto;
  }
}

return null;


}

String? _idCampo(
Map<String, dynamic> dados,
List<String> campos,
) {
for (final campo in campos) {
final valor = dados[campo];


  if (valor == null) continue;

  if (valor is Map) {
    final id = valor['_id'] ?? valor['id'];

    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString().trim();
    }

    continue;
  }

  final texto = valor.toString().trim();

  if (texto.isNotEmpty && texto != 'null') {
    return texto;
  }
}

return null;


}

String _statusVenda(Map<String, dynamic> venda) {
return _normalizar(
(venda['status'] ??
venda['Status'] ??
venda['situacao'] ??
venda['Situacao'] ??
'concluida')
.toString(),
);
}

bool _vendaConcluida(Map<String, dynamic> venda) {
final status = _statusVenda(venda);


if (status.isEmpty) return true;

return [
  'concluida',
  'concluido',
  'finalizada',
  'finalizado',
  'completed',
  'concluido',
  'concluida',
].contains(status);


}

List<Map<String, dynamic>> get vendasConcluidasBanco {
return vendasBanco.where(_vendaConcluida).toList();
}

double _valorVenda(Map<String, dynamic> venda) {
return _numero(
venda['Preco_gasto'] ??
venda['preco_gasto'] ??
venda['precoGasto'] ??
venda['valorTotal'] ??
venda['valor_total'] ??
venda['total'] ??
venda['valor'] ??
0,
);
}

double get faturamentoBanco {
return vendasConcluidasBanco.fold<double>(
0,
(total, venda) => total + _valorVenda(venda),
);
}

double get ticketMedioBanco {
if (vendasConcluidasBanco.isEmpty) return 0;


return faturamentoBanco / vendasConcluidasBanco.length;


}

int _quantidadeEstoque(Map<String, dynamic> produto) {
return _numero(
produto['quantidade'] ??
produto['Quantidade'] ??
produto['estoque'] ??
produto['Estoque'] ??
produto['stock'] ??
produto['qtd'] ??
0,
).round();
}

String _nomeProduto(Map<String, dynamic> produto) {
return _textoCampo(produto, [
'name',
'nome',
'Nome',
'nomeProduto',
'NomeProduto',
'produtoNome',
'descricao',
'Descrição',
'titulo',
]) ??
'Produto sem nome';
}

String? _idProduto(Map<String, dynamic> produto) {
return _idCampo(produto, [
'_id',
'IdProduto',
'idProduto',
'id_produto',
'produtoId',
'id',
]);
}

List<Map<String, dynamic>> get produtosEstoqueBaixo {
return produtosBanco
.where((produto) => _quantidadeEstoque(produto) <= 5)
.toList()
..sort(
(a, b) => _quantidadeEstoque(a).compareTo(_quantidadeEstoque(b)),
);
}

int get estoqueBaixoBanco => produtosEstoqueBaixo.length;

String _dinheiro(double valor) {
final negativo = valor < 0;
final absoluto = valor.abs().toStringAsFixed(2).split('.');
final parteInteira = absoluto[0];
final parteDecimal = absoluto[1];


final buffer = StringBuffer();

for (int i = 0; i < parteInteira.length; i++) {
  buffer.write(parteInteira[i]);

  final restantes = parteInteira.length - i - 1;

  if (restantes > 0 && restantes % 3 == 0) {
    buffer.write('.');
  }
}

return '${negativo ? '-' : ''}R\$ ${buffer.toString()},$parteDecimal';


}

Map<String, int> _contagemProdutosVendidos() {
final contagem = <String, int>{};
final nomesPorId = <String, String>{};


for (final produto in produtosBanco) {
  final id = _idProduto(produto);

  if (id != null) {
    nomesPorId[id] = _nomeProduto(produto);
  }
}

for (final venda in vendasConcluidasBanco) {
  final id = _idCampo(venda, [
    'IdProduto',
    'idProduto',
    'id_produto',
    'produtoId',
    'produto_id',
    'ProdutoId',
  ]);

  final nome = _textoCampo(venda, [
    'nomeProduto',
    'NomeProduto',
    'produtoNome',
    'ProdutoNome',
    'nome_produto',
    'produto',
    'Produto',
  ]);

  final chave = id ?? nome;

  if (chave == null || chave.trim().isEmpty) continue;

  final quantidade = _numero(
    venda['Quantidade'] ??
        venda['quantidade'] ??
        venda['quantity'] ??
        venda['qtd'] ??
        1,
  ).round();

  if (quantidade <= 0) continue;

  contagem[chave] = (contagem[chave] ?? 0) + quantidade;

  if (nome != null && nome.isNotEmpty) {
    nomesPorId.putIfAbsent(chave, () => nome);
  }
}

for (final chave in contagem.keys.toList()) {
  if (nomesPorId.containsKey(chave)) continue;

  final produto = produtosBanco.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item != null && _idProduto(item) == chave,
        orElse: () => null,
      );

  if (produto != null) {
    nomesPorId[chave] = _nomeProduto(produto);
  }
}

_nomesProdutosCache = nomesPorId;

return contagem;


}

Map<String, String> _nomesProdutosCache = {};

List<MapEntry<String, int>> _rankingProdutos() {
final contagem = _contagemProdutosVendidos();


final ranking = contagem.entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));

return ranking;


}

String _nomeNoRanking(String chave) {
return _nomesProdutosCache[chave] ?? chave;
}

String _respostaRankingProdutos() {
if (carregandoDados) {
return 'Estou carregando os dados dos produtos e das vendas. Tente novamente em alguns instantes.';
}


if (vendasConcluidasBanco.isEmpty) {
  return 'Ainda não encontrei vendas concluídas para montar o ranking dos produtos. Assim que houver vendas registradas, poderei mostrar quais produtos vendem mais.';
}

final ranking = _rankingProdutos();

if (ranking.isEmpty) {
  return 'Encontrei ${vendasConcluidasBanco.length} vendas concluídas, mas não consegui identificar os produtos associados a elas. Verifique se as vendas possuem o campo IdProduto e a quantidade vendida.';
}

final principais = ranking.take(5).toList();
final linhas = <String>[];

for (int i = 0; i < principais.length; i++) {
  final item = principais[i];
  final nome = _nomeNoRanking(item.key);

  linhas.add('${i + 1}. $nome — ${item.value} unidade(s)');
}

return 'Aqui está o ranking dos produtos por quantidade vendida:\n\n${linhas.join('\n')}\n\nConsiderei as quantidades registradas nas vendas concluídas. O ranking depende dos produtos que estão identificados no banco de dados.';


}

String _respostaEstoque() {
if (carregandoDados) {
return 'Estou carregando os dados do estoque. Tente novamente em alguns instantes.';
}


if (produtosBanco.isEmpty) {
  return 'Não encontrei produtos cadastrados no banco de dados. Confira se existem produtos registrados para sua empresa.';
}

if (produtosEstoqueBaixo.isEmpty) {
  return 'Boa notícia! Não encontrei produtos com estoque igual ou inferior a 5 unidades. Seu cadastro possui ${produtosBanco.length} produtos.';
}

final lista = produtosEstoqueBaixo.take(10).map((produto) {
  final nome = _nomeProduto(produto);
  final quantidade = _quantidadeEstoque(produto);

  return '• $nome — $quantidade unidade(s)';
}).join('\n');

final restante = produtosEstoqueBaixo.length > 10
    ? '\n\nExistem mais ${produtosEstoqueBaixo.length - 10} produto(s) nessa situação.'
    : '';

return 'Encontrei ${produtosEstoqueBaixo.length} produto(s) com estoque igual ou inferior a 5 unidades:\n\n$lista$restante\n\nRecomendo verificar esses itens e avaliar a necessidade de reposição.';


}

String _respostaVendas() {
if (carregandoDados) {
return 'Estou carregando as informações das vendas. Tente novamente em alguns instantes.';
}


if (erroCarregamento) {
  return 'Não consegui carregar os dados do sistema. Verifique a conexão com a API e tente novamente.';
}

if (vendasConcluidasBanco.isEmpty) {
  return 'Não encontrei vendas concluídas no banco de dados. Verifique se há vendas registradas e se o campo de status está preenchido corretamente.';
}

return 'Aqui está o resumo das suas vendas:\n\n'
    '• Vendas concluídas: ${vendasConcluidasBanco.length}\n'
    '• Faturamento: ${_dinheiro(faturamentoBanco)}\n'
    '• Ticket médio: ${_dinheiro(ticketMedioBanco)}\n\n'
    'O ticket médio representa o faturamento total dividido pela quantidade de vendas concluídas.';


}

String _respostaFaturamento() {
if (carregandoDados) {
return 'Estou carregando os dados financeiros. Tente novamente em alguns instantes.';
}


if (erroCarregamento) {
  return 'Não consegui consultar os dados financeiros. Verifique a conexão com a API e tente novamente.';
}

if (vendasConcluidasBanco.isEmpty) {
  return 'Ainda não encontrei vendas concluídas para calcular o faturamento. Quando houver vendas válidas registradas, poderei calcular o resultado.';
}

return 'Análise do faturamento:\n\n'
    '• Faturamento registrado: ${_dinheiro(faturamentoBanco)}\n'
    '• Vendas concluídas: ${vendasConcluidasBanco.length}\n'
    '• Ticket médio: ${_dinheiro(ticketMedioBanco)}\n\n'
    'Esses valores são calculados com base nos registros de vendas concluídas retornados pela API. Para comparar períodos, o sistema também precisa disponibilizar as datas das vendas.';


}

String _respostaEquipe() {
if (carregandoDados) {
return 'Estou carregando os dados da equipe. Tente novamente em alguns instantes.';
}


final ativos = funcionariosBanco.where((funcionario) {
  final status = _normalizar(
    (funcionario['status'] ??
            funcionario['Status'] ??
            funcionario['situacao'] ??
            'ativo')
        .toString(),
  );

  return status == 'ativo' || status == 'active';
}).length;

return 'Resumo da equipe:\n\n'
    '• Funcionários cadastrados: ${funcionariosBanco.length}\n'
    '• Funcionários ativos: $ativos\n'
    '• Outros status: ${funcionariosBanco.length - ativos}\n\n'
    'Essas informações são baseadas nos funcionários retornados pela API.';


}

String _responderComDados(String pergunta) {
  final q = _normalizar(pergunta);

  if (erroCarregamento) {
    return 'Não consegui acessar os dados da sua empresa agora. Confira sua conexão, entre novamente na conta e tente mais uma vez.';
  }

  if (q.contains('estoque') || q.contains('repor') || q.contains('acabando') || q.contains('baixo')) {
    return _respostaEstoque();
  }

  if (q.contains('ranking') || q.contains('mais vendido') || q.contains('mais vende') || q.contains('produto vende')) {
    return _respostaRankingProdutos();
  }

  if (q.contains('faturamento') || q.contains('ticket medio') || q.contains('financeiro') || q.contains('receita') || q.contains('quanto vendeu em dinheiro')) {
    return _respostaFaturamento();
  }

  if (q.contains('venda') || q.contains('pedido') || q.contains('desempenho')) {
    return _respostaVendas();
  }

  if (q.contains('equipe') || q.contains('funcionario') || q.contains('colaborador')) {
    return _respostaEquipe();
  }

  if (q.contains('produto') || q.contains('catalogo')) {
    if (produtosBanco.isEmpty) {
      return 'Ainda não existem produtos cadastrados para esta empresa.';
    }

    final valorEstoque = produtosBanco.fold<double>(
      0,
      (total, produto) => total + _quantidadeEstoque(produto),
    );

    return 'Resumo dos produtos cadastrados:\n\n'
        '• Produtos cadastrados: ${produtosBanco.length}\n'
        '• Unidades somadas no estoque: ${valorEstoque.toStringAsFixed(0)}\n'
        '• Produtos com estoque baixo: $estoqueBaixoBanco\n\n'
        'Posso também mostrar quais produtos precisam de reposição ou o ranking dos mais vendidos.';
  }

  if (q.contains('ola') || q.contains('oi') || q.contains('bom dia') || q.contains('boa tarde') || q.contains('boa noite')) {
    return 'Olá! Já consultei os dados disponíveis da sua empresa. Posso analisar vendas, faturamento, ticket médio, produtos mais vendidos, estoque baixo e equipe. O que você gostaria de verificar?';
  }

  return 'Posso ajudar a analisar as informações que o EasySell disponibiliza no backend. Experimente perguntar:\n\n'
      '• Como estão minhas vendas?\n'
      '• Qual é meu faturamento?\n'
      '• Quais produtos estão com estoque baixo?\n'
      '• Quais produtos vendem mais?\n'
      '• Como está minha equipe?\n\n'
      'As respostas são calculadas com os registros reais retornados pela API.';
}

@override
void dispose() {
mensagemController.dispose();
scrollController.dispose();
super.dispose();
}

Color corClara(Color cor, int alpha) => cor.withAlpha(alpha);

BoxDecoration _decoracaoCard({double raio = 24}) {
return BoxDecoration(
gradient: c.gradCard,
borderRadius: BorderRadius.circular(raio),
border: Border.all(color: c.bordaSutil),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.transparent,
body: Container(
decoration: const BoxDecoration(color: Colors.transparent),
child: SafeArea(
child: Column(
children: [
Expanded(
child: ListView(
controller: scrollController,
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.fromLTRB(19, 15, 19, 16),
children: [
_cabecalho(),
const SizedBox(height: 22),
_cardApresentacao(),
if (carregandoDados)
Padding(
padding: const EdgeInsets.only(top: 14),
child: Row(
children: [
SizedBox(
width: 15,
height: 15,
child: CircularProgressIndicator(
strokeWidth: 2,
color: c.roxoClaro,
),
),
const SizedBox(width: 9),
Text(
'Carregando dados da empresa...',
style: TextStyle(
color: c.textoSuave,
fontSize: 11,
),
),
],
),
),
if (erroCarregamento)
Padding(
padding: const EdgeInsets.only(top: 12),
child: Text(
'Não foi possível atualizar os dados. Confira sua conexão com o servidor.',
style: TextStyle(
color: c.vermelho,
fontSize: 11,
),
),
),
const SizedBox(height: 20),
...mensagens.map(_mensagem),
if (pensando) _indicadorPensando(),
const SizedBox(height: 6),
],
),
),
_sugestoes(),
_campoMensagem(),
],
),
),
),
);
}

Widget _cabecalho() {
return Row(
children: [
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
Icons.auto_awesome_rounded,
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
'ASSISTENTE INTELIGENTE',
style: TextStyle(
color: c.textoFraco,
fontSize: 9,
fontWeight: FontWeight.w800,
letterSpacing: 1.4,
),
),
const SizedBox(height: 4),
Row(
children: [
Text(
'Sell IA',
style: TextStyle(
color: c.texto,
fontSize: 19,
fontWeight: FontWeight.w900,
),
),
const SizedBox(width: 8),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 7,
vertical: 3,
),
decoration: BoxDecoration(
color: corClara(c.verde, 24),
borderRadius: BorderRadius.circular(8),
border: Border.all(color: corClara(c.verde, 38)),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.circle, color: c.verde, size: 6),
const SizedBox(width: 4),
Text(
carregandoDados ? 'Carregando' : 'Online',
style: TextStyle(
color: c.verde,
fontSize: 9,
fontWeight: FontWeight.w800,
),
),
],
),
),
],
),
],
),
),
GestureDetector(
onTap: _limparConversa,
child: Container(
width: 43,
height: 43,
decoration: BoxDecoration(
color: c.superficie,
borderRadius: BorderRadius.circular(14),
border: Border.all(color: c.bordaMedia),
),
child: Icon(
Icons.delete_outline_rounded,
color: c.texto,
size: 20,
),
),
),
],
);
}

Widget _cardApresentacao() {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: c.gradDestaque,
borderRadius: BorderRadius.circular(27),
border: Border.all(color: const Color(0x3A7C3AED)),
boxShadow: const [
BoxShadow(
color: Color(0x252563EB),
blurRadius: 30,
offset: Offset(0, 13),
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
Icons.insights_rounded,
color: Colors.white,
size: 21,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
'Seu negócio em um só lugar',
style: TextStyle(
color: c.texto,
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
),
],
),
const SizedBox(height: 14),
Text(
'Pergunte sobre suas vendas, produtos ou estoque. A Sell IA analisa as informações do seu sistema e ajuda você a tomar decisões.',
style: TextStyle(
color: c.textoSuave,
fontSize: 12,
height: 1.5,
),
),
const SizedBox(height: 18),
Container(height: 1, color: c.bordaSutil),
const SizedBox(height: 16),
Row(
children: [
_miniInfo(
Icons.trending_up_rounded,
'Vendas',
carregandoDados ? '...' : '${vendasConcluidasBanco.length}',
c.verde,
),
_miniInfo(
Icons.inventory_2_outlined,
'Produtos',
carregandoDados ? '...' : '${produtosBanco.length}',
c.azul,
),
_miniInfo(
Icons.warning_amber_rounded,
'Alertas',
carregandoDados ? '...' : '$estoqueBaixoBanco',
c.amarelo,
),
],
),
if (!carregandoDados && !erroCarregamento)
Padding(
padding: const EdgeInsets.only(top: 14),
child: Row(
children: [
Icon(
Icons.check_circle_outline_rounded,
color: c.verde,
size: 14,
),
const SizedBox(width: 6),
Expanded(
child: Text(
'Dados recebidos da API',
style: TextStyle(
color: c.textoSuave,
fontSize: 10,
),
),
),
GestureDetector(
onTap: _carregarDados,
child: Icon(
Icons.refresh_rounded,
color: c.roxoClaro,
size: 18,
),
),
],
),
),
],
),
);
}

Widget _miniInfo(
IconData icone,
String titulo,
String valor,
Color cor,
) {
return Expanded(
child: Row(
children: [
Container(
width: 27,
height: 27,
decoration: BoxDecoration(
color: corClara(cor, 24),
borderRadius: BorderRadius.circular(8),
),
child: Icon(icone, color: cor, size: 13),
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

Widget _mensagem(Map<String, dynamic> mensagem) {
final bool isIA = mensagem['tipo'] == 'ia';


return Align(
  alignment: isIA ? Alignment.centerLeft : Alignment.centerRight,
  child: Container(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.82,
    ),
    margin: EdgeInsets.only(
      bottom: 12,
      left: isIA ? 0 : 35,
      right: isIA ? 35 : 0,
    ),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      gradient: isIA ? c.gradCard : AppCores.gradRoxo,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(19),
        topRight: const Radius.circular(19),
        bottomLeft: Radius.circular(isIA ? 5 : 19),
        bottomRight: Radius.circular(isIA ? 19 : 5),
      ),
      border: isIA ? Border.all(color: c.bordaSutil) : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isIA)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: c.roxoClaro,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  'Sell IA',
                  style: TextStyle(
                    color: c.roxoClaro,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        Text(
          mensagem['texto']?.toString() ?? '',
          style: TextStyle(
            color: isIA ? c.texto : Colors.white,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    ),
  ),
);


}

Widget _indicadorPensando() {
return Align(
alignment: Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 13,
),
decoration: _decoracaoCard(raio: 18),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
SizedBox(
width: 15,
height: 15,
child: CircularProgressIndicator(
strokeWidth: 2,
color: c.roxoClaro,
),
),
const SizedBox(width: 10),
Text(
'Analisando...',
style: TextStyle(color: c.textoSuave, fontSize: 11),
),
],
),
),
);
}

Widget _sugestoes() {
const sugestoes = [
{
'texto': 'Como estão minhas vendas?',
'icone': Icons.trending_up_rounded,
},
{
'texto': 'Quais produtos estão vendendo mais?',
'icone': Icons.star_outline_rounded,
},
{
'texto': 'Tenho produtos com estoque baixo?',
'icone': Icons.inventory_2_outlined,
},
{
'texto': 'Analise meu faturamento',
'icone': Icons.analytics_outlined,
},
];


return SizedBox(
  height: 46,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 19),
    itemCount: sugestoes.length,
    itemBuilder: (context, index) {
      final sugestao = sugestoes[index];

      return GestureDetector(
        onTap: () => _enviarMensagem(sugestao['texto'] as String),
        child: Container(
          margin: const EdgeInsets.only(right: 8, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.bordaMedia),
          ),
          child: Row(
            children: [
              Icon(
                sugestao['icone'] as IconData,
                color: c.roxoClaro,
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                sugestao['texto'] as String,
                style: TextStyle(
                  color: c.textoSuave,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);


}

Widget _campoMensagem() {
return Padding(
padding: const EdgeInsets.fromLTRB(19, 6, 19, 12),
child: Container(
padding: const EdgeInsets.only(left: 16, right: 7),
decoration: BoxDecoration(
color: c.superficie,
borderRadius: BorderRadius.circular(20),
border: Border.all(color: c.bordaMedia),
),
child: Row(
children: [
Expanded(
child: TextField(
controller: mensagemController,
style: TextStyle(color: c.texto, fontSize: 12),
cursorColor: c.roxoClaro,
minLines: 1,
maxLines: 4,
textInputAction: TextInputAction.send,
onSubmitted: (_) => _enviarMensagem(mensagemController.text),
decoration: InputDecoration(
hintText: 'Pergunte algo para a Sell IA...',
hintStyle: TextStyle(
color: c.textoFraco,
fontSize: 12,
),
border: InputBorder.none,
),
),
),
GestureDetector(
onTap: () => _enviarMensagem(mensagemController.text),
child: Container(
width: 42,
height: 42,
decoration: BoxDecoration(
gradient: AppCores.gradRoxo,
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.arrow_upward_rounded,
color: Colors.white,
size: 20,
),
),
),
],
),
),
);
}

Future<void> _enviarMensagem(String texto) async {
  texto = texto.trim();

  if (texto.isEmpty || pensando) return;

  setState(() {
    mensagens.add({
      'tipo': 'usuario',
      'texto': texto,
    });
    mensagemController.clear();
    pensando = true;
  });

  _irParaFinal();

  try {
    await _carregarDados();
    final resposta = _responderComDados(texto);

    if (!mounted) return;

    setState(() {
      pensando = false;
      mensagens.add({
        'tipo': 'ia',
        'texto': resposta,
      });
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      pensando = false;
      mensagens.add({
        'tipo': 'ia',
        'texto': 'Não consegui consultar a Sell IA agora. ${e.toString().replaceFirst('Exception: ', '')}',
      });
    });
  }

  _irParaFinal();
}

void _irParaFinal() {
WidgetsBinding.instance.addPostFrameCallback((_) {
if (!scrollController.hasClients) return;


  scrollController.animateTo(
    scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
});


}

void _limparConversa() {
showDialog(
context: context,
builder: (dialogContext) {
return Dialog(
backgroundColor: Colors.transparent,
insetPadding: const EdgeInsets.symmetric(horizontal: 26),
child: Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
gradient: c.gradSheet,
borderRadius: BorderRadius.circular(27),
border: Border.all(color: c.bordaMedia),
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 58,
height: 58,
decoration: BoxDecoration(
color: corClara(c.vermelho, 32),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: corClara(c.vermelho, 42),
),
),
child: Icon(
Icons.delete_outline_rounded,
color: c.vermelho,
size: 26,
),
),
const SizedBox(height: 16),
Text(
'Limpar conversa?',
style: TextStyle(
color: c.texto,
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 8),
Text(
'Todas as mensagens desta conversa serão removidas.',
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
onPressed: () => Navigator.pop(dialogContext),
style: OutlinedButton.styleFrom(
foregroundColor: c.textoSuave,
side: BorderSide(color: c.bordaMedia),
padding: const EdgeInsets.symmetric(
vertical: 15,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
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
setState(() {
mensagens
..clear()
..add({
'tipo': 'ia',
'texto':
'Conversa limpa. Como posso ajudar você agora? 👋',
});
});

                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.vermelho,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Limpar',
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
