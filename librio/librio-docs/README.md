# Librio Docs

Documentação técnica completa do aplicativo Librio - um sistema de troca de livros desenvolvido em Flutter.

## 🚀 Funcionalidades

### 🔍 Sistema de Pesquisa

O site de documentação agora possui um sistema de pesquisa local integrado que permite:

- **Pesquisa em tempo real** através de todos os documentos
- **Suporte ao português** com resultados relevantes
- **Interface intuitiva** com barra de pesquisa no cabeçalho
- **Indexação completa** de todo o conteúdo markdown

#### Como usar a pesquisa:
1. Clique na barra de pesquisa no canto superior direito
2. Digite sua consulta (suporta português e inglês)
3. Navegue pelos resultados usando as setas do teclado
4. Pressione Enter para abrir o resultado selecionado

### 📚 Conteúdo da Documentação

- **Configuração**: Ambiente de desenvolvimento e instalação
- **Arquitetura**: Clean Architecture e design patterns
- **Firebase**: Configuração e integração
- **Funcionalidades**: Detalhes técnicos de cada feature
- **Testes**: Estratégias e implementação de testes
- **Deploy**: Processo de publicação

## 🛠️ Desenvolvimento

### Executar localmente

```bash
npm install
npm start
```

### Build para produção

```bash
npm run build
npm run serve
```

### Personalização

O site usa Docusaurus 3.8+ com:
- Plugin de pesquisa local (`@easyops-cn/docusaurus-search-local`)
- Tema Mermaid para diagramas
- Suporte completo ao português
- Design responsivo e moderno

## 📖 Como contribuir

1. Edite os arquivos markdown em `/docs`
2. A pesquisa será automaticamente atualizada
3. Use diagramas Mermaid para visualizações
4. Mantenha a estrutura de pastas organizada

## 🔧 Configuração Técnica

### Plugin de Pesquisa

```typescript
// docusaurus.config.ts
plugins: [
  [
    require.resolve("@easyops-cn/docusaurus-search-local"),
    {
      hashed: true,
      language: ["pt", "en"],
      indexDocs: true,
      indexBlog: false,
      indexPages: false,
      docsRouteBasePath: '/',
      searchBarPosition: 'right',
    },
  ],
],
```

### Estrutura de Arquivos

```
docs/
├── intro.md              # Página inicial
├── setup/                # Configuração
├── architecture/         # Arquitetura
├── firebase/            # Backend
├── features/            # Funcionalidades
├── testing/             # Testes
└── deployment/          # Deploy
```

## 📱 Sobre o Projeto Librio

O Librio é um aplicativo móvel que facilita a troca de livros entre usuários, promovendo sustentabilidade e democratização do acesso à leitura.

### Stack Tecnológico
- **Frontend**: Flutter + Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Arquitetura**: Clean Architecture
- **Estado**: Provider
- **Navegação**: GoRouter

---

**Desenvolvido com ❤️ usando Docusaurus**
