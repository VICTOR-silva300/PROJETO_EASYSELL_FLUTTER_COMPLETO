<div align="center">

# 💼 EasySell

### Gestão de vendas, produtos, estoque e equipe — direto no seu celular.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Web](https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

</div>

---

## ✨ Sobre o projeto

O **EasySell** é um aplicativo Flutter para pequenos e médios negócios acompanharem o dia a dia da operação em um só lugar: vendas, produtos, estoque, finanças e equipe, com a ajuda de assistentes inteligentes.

O visual foi pensado para ser moderno e confortável, com **tema claro e escuro** em todo o app e um fundo decorativo inspirado na tela de login.

## 🚀 Funcionalidades

| Seção | O que você faz |
|---|---|
| 📊 **Resumo** | Visão geral do negócio |
| 🏠 **Início** | Painel principal com atalhos |
| 🛍️ **Produtos** | Cadastro, edição e exclusão de produtos |
| 📦 **Estoque** | Controle do que você tem disponível |
| 💰 **Vendas** | Registro e acompanhamento de vendas |
| 📈 **Financeiro** | Visão financeira baseada nas vendas |
| 👥 **Equipe** | Gestão de funcionários |
| 🏢 **Empresa** | Dados e configurações da empresa |
| 🤖 **Sell IA** | Assistente que analisa suas vendas, produtos, estoque e equipe |
| 💬 **EasyBot** | Chat de assistência dentro do app |
| ⚙️ **Configurações** | Tema claro/escuro e preferências |
| 🙋 **Conta** | Perfil com foto, ajuda e suporte, sobre o app |

### 🔐 Autenticação

- Login e cadastro de usuário
- Recuperação de senha ("Esqueci minha senha") e definição de nova senha
- Sessão com token (Bearer) nas chamadas à API

## 🧰 Tecnologias

- [Flutter](https://flutter.dev) (Dart `^3.10.8`)
- [`http`](https://pub.dev/packages/http) — comunicação com a API
- [`google_fonts`](https://pub.dev/packages/google_fonts) — tipografia
- [`image_picker`](https://pub.dev/packages/image_picker) — foto de perfil
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — armazenamento local

## 📁 Estrutura

```text
lib/
├── main.dart              # Ponto de entrada e configuração de tema
├── tema.dart              # Paletas claro/escuro (AppTema)
├── app_shell.dart         # Navegação principal (menu lateral + barra inferior)
├── api_service.dart       # Cliente da API (auth, produtos, vendas, equipe, empresa)
│
├── login_page.dart        # Login
├── cadastro.dart          # Cadastro
├── esqueci_senha.dart     # Recuperação de senha
├── nova_senha.dart        # Redefinição de senha
│
├── resumo.dart            # Resumo
├── home.dart              # Início
├── produtos.dart          # Produtos
├── estoque.dart           # Estoque
├── vendas.dart            # Vendas
├── financas.dart          # Financeiro
├── equipe.dart            # Equipe
├── empresa.dart           # Empresa
│
├── sell_ia.dart           # Sell IA
├── easybot.dart           # EasyBot
│
├── perfil.dart            # Perfil
├── configuracoes.dart     # Configurações
├── opcoes.dart            # Opções
├── ajuda_suporte.dart     # Ajuda e suporte
├── sobre.dart             # Sobre
│
└── profile_photo*.dart    # Foto de perfil (implementações web e demais plataformas)
```

## ▶️ Como rodar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatível com Dart `^3.10.8`
- Android Studio / VS Code com as extensões do Flutter

### Passo a passo

```bash
# 1. Clone o repositório
git clone https://github.com/<seu-usuario>/PROJETO-EASYSELL.git
cd PROJETO-EASYSELL

# 2. Instale as dependências
flutter pub get

# 3. Rode o app
flutter run                 # dispositivo/emulador conectado
flutter run -d chrome       # navegador
flutter run -d windows      # desktop Windows
```

### Gerar build

```bash
flutter build apk --release   # Android
flutter build web --release   # Web
```

## 🔌 Configuração da API

O app consome uma API REST hospedada no Render. A URL base fica em `lib/api_service.dart`:

```dart
static const String baseUrl = 'https://easysellback.onrender.com';
```

> 💡 Para usar outro servidor (por exemplo, local), altere esse valor. Não coloque `/` no final.
>
> ⏳ Em hospedagens gratuitas, a primeira requisição pode demorar alguns segundos enquanto o servidor "acorda".

## 🎨 Temas

O botão de modo escuro em **Configurações** alterna o app inteiro entre claro e escuro. As cores ficam centralizadas em `lib/tema.dart`, então dá para ajustar a identidade visual em um só lugar.

## 📱 Plataformas suportadas

- ✅ Android
- ✅ Web
- ✅ Windows


<div align="center">

Feito com 💙 e Flutter

</div>