# Postech Finance 04

Aplicativo mobile de controle financeiro pessoal desenvolvido em Flutter para dispositivos Android como parte do Tech Challenge 4 da Pós-Tech FIAP.

## Sobre o Projeto

O Postech Finance é um aplicativo de gestão financeira que permite aos usuários:

- Visualizar dashboard com resumo financeiro (receitas, despesas e saldo)
- Cadastrar transações financeiras (receitas e despesas)
- Acompanhar gráficos e estatísticas financeiras
- Autenticação segura com verificação de email e TOTP (MFA)
- Gerenciamento de perfil com foto
- Interface otimizada para Android

## Tecnologias Utilizadas

- **Flutter** ^3.10.4 - Framework para desenvolvimento mobile
- **Firebase Core** - Integração com Firebase
- **Firebase Auth** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Firebase Storage** - Armazenamento de comprovantes de transações
- **Firebase Crashlytics** - Monitoramento de crashes em produção
- **Firebase Performance** - Métricas de performance do app
- **Provider** - Gerenciamento de estado
- **FL Chart** - Gráficos e visualizações
- **Image Picker** - Seleção de imagens da galeria/câmera
- **Cached Network Image** - Cache de imagens para performance
- **OTP** - Geração e validação de códigos TOTP
- **QR Flutter** - Geração de QR Codes para setup de TOTP
- **Flutter Secure Storage** - Armazenamento seguro de secrets

## Pré-requisitos

Antes de iniciar, certifique-se de ter instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.10.4 ou superior)
- [Android Studio](https://developer.android.com/studio) com Android SDK
- Dispositivo Android físico ou emulador configurado
- Git

## Configuração e Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/GM-Ferreira/postech-finance-04.git
cd postech-finance-04
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Configure o Firebase

**IMPORTANTE:** Este projeto requer credenciais Firebase para funcionar. As credenciais foram fornecidas separadamente por motivos de segurança.

Siga as instruções do arquivo `credenciais-firebase-guilherme.txt` para configurar:

1. Abra o arquivo `lib/firebase_options.dart`
2. Localize a classe `FirebaseOptions android`
3. Substitua os valores de:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`
   - `storageBucket`

Pelos valores fornecidos no arquivo de credenciais.

**Exemplo da estrutura esperada:**

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'SUA-API-KEY-AQUI',
  appId: 'SEU-APP-ID-AQUI',
  messagingSenderId: 'SEU-MESSAGING-SENDER-ID-AQUI',
  projectId: 'SEU-PROJECT-ID-AQUI',
  storageBucket: 'SEU-STORAGE-BUCKET-AQUI',
);
```

### 4. Execute o aplicativo

**Pré-requisito:** Tenha um emulador Android iniciado (via Android Studio AVD Manager) ou um dispositivo físico conectado via USB.

#### Opção 1: Via VS Code (Interface Gráfica)

1. Inicie um emulador Android pelo Android Studio ou conecte um dispositivo físico
2. No VS Code, selecione o dispositivo no canto inferior direito
3. Pressione F5 ou clique em "Run" > "Start Debugging"

#### Opção 2: Via Terminal

Verifique os dispositivos disponíveis:

```bash
flutter devices
```

Execute no dispositivo/emulador Android:

```bash
flutter run
```

Ou especifique o dispositivo:

```bash
flutter run -d <device-id>
```

## Plataforma Suportada

Este projeto foi desenvolvido e testado especificamente para **Android**. Outras plataformas (iOS, Web, Desktop) não foram configuradas.

## Estrutura do Projeto

```
lib/
├── app.dart                    # Configuração principal + AuthWrapper + DI (Composition Root)
├── main.dart                   # Ponto de entrada + Crashlytics setup
├── firebase_options.dart       # Configurações do Firebase
├── config/
│   └── app_theme.dart         # Tema e estilos
├── extensions/
│   └── transaction_extensions.dart  # Extensions para Transaction
├── models/                    # Modelos de domínio (puros, sem dependência Firebase)
│   ├── app_user.dart          # Modelo de usuário autenticado
│   ├── auth_exception.dart    # Exceção de domínio para autenticação
│   └── transaction.dart       # Modelo de transação financeira
├── providers/                 # Gerenciadores de estado (Provider)
│   ├── auth_provider.dart     # Estado de autenticação + TOTP + Observabilidade
│   └── transaction_provider.dart
├── repositories/              # Camada de dados (interfaces + implementações)
│   ├── i_auth_repository.dart       # Interface de autenticação
│   ├── auth_repository.dart         # Implementação Firebase Auth
│   ├── i_totp_repository.dart       # Interface TOTP
│   ├── totp_repository.dart         # Implementação TOTP (OTP + SecureStorage + Firestore)
│   ├── i_storage_repository.dart    # Interface de storage
│   ├── storage_repository.dart      # Implementação Firebase Storage
│   └── transaction_repository.dart  # Repositório de transações
├── screens/                   # Telas do aplicativo
│   ├── auth/                 # Autenticação
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── email_verification_screen.dart  # Verificação de email obrigatória
│   │   ├── totp_setup_screen.dart          # QR Code + ativação TOTP
│   │   └── totp_verification_screen.dart   # Verificação de código TOTP no login
│   ├── home/                 # Dashboard
│   ├── profile/              # Perfil do usuário + toggle 2FA
│   └── transactions/         # Transações financeiras
├── services/                  # Serviços
│   ├── i_image_picker_service.dart    # Interface de seleção de imagens
│   ├── image_picker_service.dart      # Implementação Image Picker
│   └── observability_service.dart     # Crashlytics + Performance centralizado
├── utils/                     # Utilitários e helpers
│   └── validators.dart        # Validações (email, senha forte)
└── widgets/                   # Componentes reutilizáveis
    ├── common/
    │   ├── app_drawer.dart              # Drawer global (navegação em todas as telas)
    │   ├── password_strength_indicator.dart  # Indicador visual de força de senha
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   └── receipt_viewer.dart          # Viewer de comprovantes com cache
    └── dashboard/
        ├── balance_card.dart
        ├── category_pie_chart.dart
        └── monthly_bar_chart.dart
```

## Segurança

O projeto implementa:

- **Senha forte obrigatória** — mínimo 8 caracteres, maiúscula, minúscula, número e símbolo, com indicador visual em tempo real
- **Verificação de email obrigatória** — conta só é ativada após confirmar o email
- **TOTP (MFA)** — autenticação em dois fatores via Google Authenticator/Authy, configurável no perfil
- **Proteção contra bypass de TOTP** — verificação persiste mesmo após minimizar/fechar o app
- Autenticação Firebase para garantir acesso seguro
- Firebase Security Rules configuradas para acesso baseado em `userId`
- Cada usuário só pode visualizar e modificar seus próprios dados
- Secrets TOTP armazenados no Flutter Secure Storage (não no Firestore)
- Credenciais Firebase separadas do código-fonte

## Funcionalidades Principais

### Autenticação

- Login com email e senha
- Cadastro com validação de senha forte + indicador visual
- Verificação de email obrigatória
- TOTP (2FA) — ativação via QR Code, verificação no login
- Logout seguro

### Dashboard

- Resumo financeiro (receitas, despesas, saldo)
- Gráficos visuais de despesas por categoria
- Visualização de transações recentes

### Transações

- Cadastro de receitas e despesas
- Categorização de transações
- Histórico completo de movimentações
- Comprovantes com cache de imagens

### Perfil

- Visualização dos dados do usuário
- Edição de dados do perfil e troca de senha
- Ativar/desativar autenticação em dois fatores (TOTP)

### Observabilidade

- Firebase Crashlytics — monitoramento de crashes e erros em produção
- Firebase Performance — métricas de tempo de inicialização, traces customizados e rede

## Arquitetura

O projeto segue princípios de **Clean Architecture**:

- **Models** — modelos de domínio puros, sem dependência de Firebase
- **Repositories** — interfaces abstratas (ex: `IAuthRepository`) com implementações concretas (ex: `AuthRepository`)
- **Providers** — gerenciadores de estado que dependem apenas das interfaces
- **Composition Root** — injeção de dependências centralizada no `app.dart` via `MultiProvider`
- **dart analyze** — 0 issues

## Suporte

Em caso de dúvidas ou problemas durante a configuração, verifique:

1. Se o Flutter está instalado corretamente: `flutter doctor`
2. Se as credenciais do Firebase foram configuradas corretamente
3. Se há um dispositivo/emulador Android conectado: `flutter devices`

## Desenvolvimento

Desenvolvido como parte do Tech Challenge 4 - Pós-Tech FIAP

---

**Observação:** Este é um projeto acadêmico desenvolvido para fins educacionais.
