# Postech Finance 03

Aplicativo mobile de controle financeiro pessoal desenvolvido em Flutter para dispositivos Android como parte do Tech Challenge 3 da Pós-Tech FIAP.

## Sobre o Projeto

O Postech Finance é um aplicativo de gestão financeira que permite aos usuários:

- Visualizar dashboard com resumo financeiro (receitas, despesas e saldo)
- Cadastrar transações financeiras (receitas e despesas)
- Acompanhar gráficos e estatísticas financeiras
- Autenticação segura de usuários
- Gerenciamento de perfil com foto
- Interface otimizada para Android

## Tecnologias Utilizadas

- **Flutter** ^3.10.4 - Framework para desenvolvimento mobile
- **Firebase Core** - Integração com Firebase
- **Firebase Auth** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Firebase Storage** - Armazenamento de comprovantes de transações
- **Provider** - Gerenciamento de estado
- **FL Chart** - Gráficos e visualizações
- **Image Picker** - Seleção de imagens da galeria/câmera

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
├── app.dart                    # Configuração principal do app
├── main.dart                   # Ponto de entrada
├── firebase_options.dart       # Configurações do Firebase
├── config/
│   └── app_theme.dart         # Tema e estilos
├── models/                    # Modelos de dados
├── providers/                 # Gerenciadores de estado (Provider)
│   ├── auth_provider.dart
│   └── transaction_provider.dart
├── screens/                   # Telas do aplicativo
│   ├── auth/                 # Telas de autenticação
│   ├── home/                 # Dashboard
│   ├── profile/              # Perfil do usuário
│   └── transactions/         # Transações financeiras
├── services/                  # Serviços (Firebase Storage)
├── utils/                     # Utilitários e helpers
└── widgets/                   # Componentes reutilizáveis
```

## Segurança

O projeto implementa:

- Autenticação Firebase para garantir acesso seguro
- Firebase Security Rules configuradas para acesso baseado em `userId`
- Cada usuário só pode visualizar e modificar seus próprios dados
- Credenciais Firebase separadas do código-fonte

## Funcionalidades Principais

### Autenticação

- Login com email e senha
- Cadastro de novos usuários
- Logout seguro

### Dashboard

- Resumo financeiro (receitas, despesas, saldo)
- Gráficos visuais de despesas por categoria
- Visualização de transações recentes

### Transações

- Cadastro de receitas e despesas
- Categorização de transações
- Histórico completo de movimentações

### Perfil

- Visualização dos dados do usuário
- Edição de dados do perfil e troca de senha

## Suporte

Em caso de dúvidas ou problemas durante a configuração, verifique:

1. Se o Flutter está instalado corretamente: `flutter doctor`
2. Se as credenciais do Firebase foram configuradas corretamente
3. Se há um dispositivo/emulador Android conectado: `flutter devices`

## Desenvolvimento

Desenvolvido como parte do Tech Challenge 3 - Pós-Tech FIAP

---

**Observação:** Este é um projeto acadêmico desenvolvido para fins educacionais.
