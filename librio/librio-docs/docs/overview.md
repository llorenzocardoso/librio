# Visão Geral Completa do Librio

O **Librio** é um aplicativo móvel que conecta leitores através de um sistema de troca de livros seguro e eficiente, promovendo o compartilhamento de conhecimento e sustentabilidade.

## 🎯 Missão do Projeto

Democratizar o acesso à leitura através de uma plataforma que permite aos usuários trocarem livros de forma prática, segura e sustentável, criando uma comunidade de leitores engajados.

## 🏗️ Arquitetura Geral do Sistema

```mermaid
flowchart TB
    subgraph "📱 Cliente Flutter"
        A[Presentation Layer]
        B[Domain Layer]
        C[Data Layer]
    end

    subgraph "☁️ Firebase Backend"
        D[Authentication]
        E[Firestore Database]
        F[Cloud Storage]
        G[Cloud Functions]
    end

    subgraph "🔧 Recursos"
        H[Push Notifications]
        I[Image Compression]
        J[Offline Support]
    end

    A --> B
    B --> C
    C --> D
    C --> E
    C --> F
    E --> G

    A --> H
    C --> I
    C --> J
```

## 📋 Funcionalidades Principais

### 1. 🔐 Sistema de Autenticação
- **Login/Cadastro** com email e senha
- **Perfis de usuário** com foto e biografia
- **Sistema de reputação** baseado em avaliações
- **Gerenciamento de sessão** seguro

**Tecnologias**: Firebase Authentication, validação de formulários

### 2. 📚 Gerenciamento de Livros
- **Cadastro de livros** com imagem obrigatória
- **14 categorias padronizadas** (Ficção, Romance, Fantasia, etc.)
- **5 condições de conservação** (Novo, Bom, Razoável, etc.)
- **Upload para Cloud Storage** com compressão automática

**Tecnologias**: Firebase Storage, Image Picker, validação de formato

### 3. 🔍 Busca e Filtros Avançados
- **Busca em tempo real** por título, autor, gênero
- **Filtros por categoria** com interface intuitiva
- **Algoritmo de relevância** inteligente
- **Chips informativos** dos filtros ativos

**Tecnologias**: Algoritmos de busca local, UI responsiva

### 4. 🔄 Sistema de Trocas Completo
- **Propostas de troca** entre usuários
- **Timeout automático** de 48 horas
- **Exclusão automática** de livros após troca
- **Histórico detalhado** com fotos dos participantes

**Tecnologias**: Firestore Transactions, Cloud Functions para timeout

### 5. 💬 Chat em Tempo Real
- **Mensagens instantâneas** entre usuários
- **Criação automática** quando troca é aceita
- **Interface moderna** com bolhas de mensagem
- **Indicadores de leitura** e typing

**Tecnologias**: Firestore Real-time Listeners, Stream de dados

### 6. 🔔 Sistema de Notificações
- **Notificações contextuais** para cada tipo de evento
- **Contador inteligente** no ícone de notificação
- **Filtragem automática** de notificações já vistas
- **Ações rápidas** diretamente das notificações

**Tecnologias**: Estado local + Firestore, gestão de badges

### 7. ⭐ Sistema de Avaliações
- **Avaliações pós-troca** obrigatórias
- **Sistema de 5 estrelas** com comentários
- **Cálculo automático** de média de reputação
- **Prevenção de auto-avaliação** e duplicatas

**Tecnologias**: Validações de negócio, cálculos estatísticos

## 🗄️ Estrutura do Banco de Dados

### Modelo Entidade-Relacionamento Simplificado

```mermaid
erDiagram
    USERS {
        string id PK "ID único do usuário"
        string name "Nome completo"
        string email "Email de login"
        string photoUrl "URL da foto de perfil"
        string description "Biografia do usuário"
        double averageRating "Avaliação média (0-5)"
        int ratingCount "Total de avaliações recebidas"
        int exchangeCount "Total de trocas realizadas"
        timestamp createdAt "Data de criação"
        timestamp updatedAt "Última atualização"
    }

    BOOKS {
        string id PK "ID único do livro"
        string title "Título da obra"
        string author "Nome do autor"
        string genre "Categoria/Gênero"
        string condition "Estado de conservação"
        string imageUrl "URL da foto do livro"
        string ownerId FK "Referência ao proprietário"
        boolean available "Disponível para troca"
        timestamp createdAt "Data de cadastro"
        timestamp updatedAt "Última atualização"
    }

    EXCHANGES {
        string id PK "ID único da troca"
        string proposerId FK "Usuário que propôs"
        string receiverId FK "Usuário que recebeu proposta"
        string proposerBookId FK "Livro oferecido"
        string receiverBookId FK "Livro desejado"
        string status "pending/accepted/completed"
        boolean proposerConfirmed "Confirmação do proponente"
        boolean receiverConfirmed "Confirmação do receptor"
        timestamp proposerConfirmedAt "Data confirmação proponente"
        timestamp receiverConfirmedAt "Data confirmação receptor"
        timestamp createdAt "Data da proposta"
        timestamp updatedAt "Última atualização"
    }

    CHATS {
        string id PK "ID único do chat"
        string exchangeId FK "Referência à troca"
        array participantIds "IDs dos participantes"
        timestamp lastMessageAt "Última mensagem em"
        string lastMessage "Prévia da última mensagem"
        timestamp createdAt "Data de criação"
    }

    MESSAGES {
        string id PK "ID única da mensagem"
        string chatId FK "Referência ao chat"
        string senderId FK "Usuário remetente"
        string content "Conteúdo da mensagem"
        boolean isRead "Mensagem foi lida"
        timestamp createdAt "Data de envio"
    }

    RATINGS {
        string id PK "ID única da avaliação"
        string exchangeId FK "Referência à troca avaliada"
        string evaluatorId FK "Usuário que avalia"
        string evaluatedUserId FK "Usuário sendo avaliado"
        int rating "Nota de 1 a 5 estrelas"
        string comment "Comentário opcional"
        timestamp createdAt "Data da avaliação"
    }

    %% Relacionamentos principais
    USERS ||--o{ BOOKS : "possui"
    USERS ||--o{ EXCHANGES : "participa"
    USERS ||--o{ RATINGS : "avalia/é_avaliado"
    USERS ||--o{ MESSAGES : "envia"

    BOOKS ||--o{ EXCHANGES : "envolvido_em"
    EXCHANGES ||--|| CHATS : "gera"
    EXCHANGES ||--o{ RATINGS : "resulta_em"
    CHATS ||--o{ MESSAGES : "contém"
```

### Relacionamentos Detalhados

**1. USERS ↔ BOOKS** (1:N)
- Um usuário pode cadastrar múltiplos livros
- Cada livro pertence a exatamente um usuário

**2. USERS ↔ EXCHANGES** (N:M)
- Usuários participam de trocas como proponente ou receptor
- Cada troca envolve exatamente dois usuários

**3. BOOKS ↔ EXCHANGES** (N:M)
- Livros são objetos das propostas de troca
- Cada troca envolve exatamente dois livros

**4. EXCHANGES → CHATS** (1:1)
- Cada troca aceita gera automaticamente um chat
- Chat é criado apenas quando troca é aceita

**5. CHATS ↔ MESSAGES** (1:N)
- Cada chat contém múltiplas mensagens
- Mensagens pertencem a exatamente um chat

**6. EXCHANGES ↔ RATINGS** (1:N)
- Trocas concluídas geram avaliações mútuas
- Máximo de 2 ratings por troca (uma para cada participante)

---

### Versão Compacta para TCC/Impressão

```mermaid
flowchart TD
    subgraph Core["🔐 Entidades Principais"]
        U["`**USERS**
        • id (PK)
        • name, email
        • photoUrl, description
        • averageRating, ratingCount
        • exchangeCount
        • createdAt, updatedAt`"]

        B["`**BOOKS**
        • id (PK)
        • title, author, genre
        • condition, imageUrl
        • ownerId (FK→USERS)
        • available
        • createdAt, updatedAt`"]
    end

    subgraph Exchange["💱 Sistema de Trocas"]
        E["`**EXCHANGES**
        • id (PK)
        • proposerId, receiverId (FK→USERS)
        • proposerBookId, receiverBookId (FK→BOOKS)
        • status: pending/accepted/completed
        • proposerConfirmed, receiverConfirmed
        • proposerConfirmedAt, receiverConfirmedAt
        • createdAt, updatedAt`"]
    end

    subgraph Communication["💬 Comunicação"]
        C["`**CHATS**
        • id (PK)
        • exchangeId (FK→EXCHANGES)
        • participantIds []
        • lastMessageAt, lastMessage
        • createdAt`"]

        M["`**MESSAGES**
        • id (PK)
        • chatId (FK→CHATS)
        • senderId (FK→USERS)
        • content, isRead
        • createdAt`"]
    end

    subgraph Evaluation["⭐ Avaliações"]
        R["`**RATINGS**
        • id (PK)
        • exchangeId (FK→EXCHANGES)
        • evaluatorId, evaluatedUserId (FK→USERS)
        • rating (1-5), comment
        • createdAt`"]
    end

    %% Relacionamentos
    U ---|1:N| B
    U ---|N:M| E
    B ---|N:M| E
    E ---|1:1| C
    C ---|1:N| M
    U ---|1:N| M
    E ---|1:2| R
    U ---|N:M| R
```

### Versão Minimalista (Ideal para TCC)

```mermaid
graph TB
    subgraph DB["📊 BANCO DE DADOS - LIBRIO"]
        direction TB

        subgraph T1[" "]
            U["👤 USERS<br/>name, email, rating"]
            B["📚 BOOKS<br/>title, author, condition"]
        end

        subgraph T2[" "]
            E["🔄 EXCHANGES<br/>status, confirmed"]
            C["💬 CHATS<br/>messages"]
        end

        subgraph T3[" "]
            M["✉️ MESSAGES<br/>content, read"]
            R["⭐ RATINGS<br/>score, comment"]
        end
    end

    %% Relacionamentos simples
    U -.owns.-> B
    U -.proposes.-> E
    B -.involved.-> E
    E -.creates.-> C
    C -.contains.-> M
    E -.generates.-> R
```

**Legendas:**
- **1:N** = Um para muitos (ex: 1 usuário possui N livros)
- **N:M** = Muitos para muitos (ex: N usuários fazem M trocas)
- **1:1** = Um para um (ex: 1 troca gera 1 chat)

## 🎨 Design System

### Paleta de Cores
- **Primária**: Azul (#2196F3) - Confiança e segurança
- **Secundária**: Verde (#4CAF50) - Sucesso e confirmação
- **Acento**: Âmbar (#FFC107) - Destaque e avaliações
- **Erro**: Vermelho (#F44336) - Alertas e erros
- **Neutro**: Cinza (#9E9E9E) - Textos secundários

### Tipografia
- **Título Principal**: 32px, Bold
- **Títulos Seção**: 20px, Bold
- **Corpo**: 14px, Regular
- **Legenda**: 12px, Regular

### Componentes Reutilizáveis
- **BookCard**: Card de livro com imagem e detalhes
- **NotificationCard**: Card de notificação contextual
- **ExchangeCard**: Card de troca com ações
- **UserAvatar**: Avatar circular com foto de perfil
- **CategoryFilter**: Filtro horizontal com chips
- **SearchBar**: Campo de busca com limpeza

## 🔐 Segurança Implementada

### Firestore Security Rules
```javascript
// Proteção de dados por usuário
match /users/{userId} {
  allow read: if true; // Perfis públicos
  allow write: if request.auth.uid == userId;
}

// Proteção de livros
match /books/{bookId} {
  allow read: if true; // Livros públicos
  allow write: if request.auth.uid == resource.data.ownerId;
}

// Proteção de trocas
match /exchanges/{exchangeId} {
  allow read, write: if request.auth.uid in
    [resource.data.proposerId, resource.data.receiverId];
}
```

### Storage Rules
```javascript
// Proteção de imagens por usuário
match /users/{userId}/profile/{fileName} {
  allow read: if true;
  allow write: if request.auth.uid == userId
               && isValidImageFile();
}
```

## 📊 Métricas e Analytics

### Métricas de Engajamento
- **Livros cadastrados** por usuário
- **Taxa de conversão** proposta → troca
- **Tempo médio** de resposta às propostas
- **Categorias mais populares**
- **Termos de busca** mais utilizados

### Métricas de Qualidade
- **Média geral** de avaliações na plataforma
- **Taxa de completion** das trocas
- **Tempo médio** para conclusão de troca
- **Usuários mais ativos** (top rated)

## 🚀 Fluxo de Uso Típico

```mermaid
journey
    title Jornada do Usuário no Librio

    section Descoberta
      Buscar livros: 5: Usuário
      Filtrar por categoria: 4: Usuário
      Ver detalhes do livro: 5: Usuário

    section Proposta
      Propor troca: 4: Usuário
      Selecionar livro para oferta: 3: Usuário
      Aguardar resposta: 2: Usuário

    section Negociação
      Receber aceite: 5: Usuário
      Iniciar chat: 5: Usuário
      Combinar detalhes: 4: Usuário

    section Conclusão
      Confirmar troca realizada: 4: Usuário
      Avaliar experiência: 4: Usuário
      Ver nova reputação: 5: Usuário
```

## ⚡ Performance e Otimizações

### Estratégias Implementadas
- **Paginação** implícita com carregamento sob demanda
- **Cache local** de livros e perfis
- **Compressão de imagens** automática
- **Debounce** em campos de busca
- **Lazy loading** de imagens
- **Filtros locais** para resposta instantânea

### Métricas de Performance
- **Tempo de carregamento** inicial < 3s
- **Resposta de busca** < 100ms
- **Upload de imagem** < 5s (com compressão)
- **Sincronização** de mensagens < 500ms

## 🧪 Estratégia de Testes

### Cobertura de Testes
- **Unit Tests**: Lógica de negócio e use cases
- **Widget Tests**: Componentes de UI isolados
- **Integration Tests**: Fluxos completos de usuário
- **E2E Tests**: Jornadas críticas do app

### Ferramentas Utilizadas
- **Flutter Test**: Framework nativo do Flutter
- **Mockito**: Mocks para dependencies
- **Golden Tests**: Testes visuais de regressão
- **Firebase Emulator**: Testes locais do backend

## 🌟 Diferenciais Competitivos

### 1. **Sistema de Timeout Inteligente**
Trocas que não são confirmadas em 48h são automaticamente processadas, evitando livros "presos" indefinidamente.

### 2. **Busca com Relevância**
Algoritmo proprietário que considera múltiplos fatores para ordenar resultados por relevância real.

### 3. **Chat Contextual**
Chat criado automaticamente quando troca é aceita, mantendo conversas organizadas por contexto.

### 4. **Notificações Inteligentes**
Sistema que aprende quais notificações o usuário já viu, evitando spam e melhorando UX.

### 5. **Reputação Transparente**
Sistema de avaliações pós-troca que gera reputação confiável baseada em experiências reais.

## 🎓 Impacto Educacional

### Para Desenvolvedores
- **Referência de Clean Architecture** em Flutter
- **Integração completa** com Firebase
- **Padrões de UI/UX** modernos
- **Gestão de estado** com Provider
- **Boas práticas** de segurança

### Para Usuários
- **Acesso democratizado** à literatura
- **Comunidade de leitores** engajada
- **Sustentabilidade** através de reutilização
- **Descoberta** de novos livros e autores

---

:::tip Próximos Passos
Este projeto serve como base sólida para futuras expansões como marketplace de livros, grupos de leitura, recomendações por IA, e integração com bibliotecas públicas.
:::

:::info Tecnologia
O Librio demonstra como tecnologias modernas podem criar soluções que geram valor social real, conectando pessoas através do conhecimento compartilhado.
:::
