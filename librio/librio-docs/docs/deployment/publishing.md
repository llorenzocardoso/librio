# 📱 Publicação nas Lojas

## Google Play Store

### 1. Preparação do Build

```bash
# Gerar App Bundle (recomendado)
flutter build appbundle --release

# Ou APK (legacy)
flutter build apk --release --split-per-abi
```

### 2. Signing Key

```bash
# Gerar keystore
keytool -genkey -v -keystore ~/librio-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias librio

# Configurar android/key.properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=librio
storeFile=/path/to/librio-key.jks
```

### 3. Play Console

1. **Upload do App Bundle**
   - Acesse Play Console
   - Crie novo app "Librio"
   - Upload do arquivo `app-release.aab`

2. **Configuração da Store Listing**
   ```
   Título: Librio - Troca de Livros
   Descrição curta: Conecte-se com leitores e troque livros facilmente
   Descrição completa: [Ver seção Store Listing]
   ```

3. **Assets Necessários**
   - Ícone: 512x512px
   - Screenshots: 16:9 e 9:16
   - Feature graphic: 1024x500px

### 4. Configurações de Versão

```yaml
# pubspec.yaml
version: 1.0.0+1
```

## Apple App Store

### 1. Build iOS

```bash
# Abrir no Xcode
open ios/Runner.xcworkspace

# Ou via CLI
flutter build ios --release
```

### 2. Configuração do Xcode

1. **Signing & Capabilities**
   - Team: Sua conta Apple Developer
   - Bundle ID: `com.librio.app`
   - Provisioning Profile: App Store

2. **Build Settings**
   - Deployment Target: iOS 12.0+
   - Architectures: arm64

### 3. App Store Connect

1. **Criar App Record**
   - Nome: Librio
   - Bundle ID: com.librio.app
   - SKU: com.librio.app

2. **Upload via Xcode**
   - Product → Archive
   - Distribute App → App Store Connect

3. **Configuração da Store**
   - Metadata
   - Screenshots
   - App Review Information

## Store Listing Otimizada

### Título e Subtítulo
```
Título: Librio - Troca de Livros
Subtítulo: Conecte leitores e troque livros
```

### Descrição Completa

```markdown
📚 LIBRIO - A NOVA FORMA DE TROCAR LIVROS

Descubra uma comunidade apaixonada por leitura! O Librio conecta leitores de todo o Brasil para trocas inteligentes de livros.

🔸 PRINCIPAIS FUNCIONALIDADES:
• Cadastre seus livros em segundos
• Encontre livros por categoria e localização
• Proponha trocas seguras com outros leitores
• Chat integrado para combinar encontros
• Sistema de avaliações para confiança
• Histórico completo de trocas

🔸 COMO FUNCIONA:
1. Cadastre os livros que quer trocar
2. Navegue pela biblioteca da comunidade
3. Proponha trocas com outros usuários
4. Converse pelo chat integrado
5. Encontrem-se e realizem a troca
6. Avaliem a experiência

🔸 POR QUE ESCOLHER O LIBRIO:
✅ Gratuito e sem anúncios
✅ Interface simples e intuitiva
✅ Comunidade ativa e engajada
✅ Segurança com sistema de avaliações
✅ Sustentabilidade através da reutilização

Junte-se à revolução da leitura sustentável!
Baixe agora e comece a trocar livros hoje mesmo.

#LeituraParaTodos #TrocaDeLivros #Sustentabilidade
```

### Keywords (ASO)

**Principais:**
- troca de livros
- biblioteca
- leitura
- livros usados
- comunidade leitores

**Secundárias:**
- sebo digital
- troca sustentável
- livros grátis
- biblioteca compartilhada
- reading community

## Screenshots e Assets

### Screenshots Necessários

**Android (Play Store):**
- Phone: 1080x1920px (mínimo 2 screenshots)
- Tablet 7": 1200x1920px
- Tablet 10": 1920x1200px

**iOS (App Store):**
- iPhone 6.7": 1290x2796px
- iPhone 6.5": 1242x2688px
- iPhone 5.5": 1242x2208px
- iPad Pro 12.9": 2048x2732px

### Conteúdo dos Screenshots

1. **Tela Home** - "Descubra milhares de livros"
2. **Detalhes do Livro** - "Veja informações completas"
3. **Chat** - "Converse com outros leitores"
4. **Perfil** - "Gerencie sua biblioteca"
5. **Propostas** - "Receba e faça propostas"

### Feature Graphic (Google Play)

Dimensões: 1024x500px
Elementos:
- Logo do Librio
- Mockups do app
- Texto: "Troque Livros, Compartilhe Conhecimento"
- Cores da marca

## Processo de Review

### Google Play Review

**Checklist:**
- [ ] Política de Conteúdo ✅
- [ ] Dados do Usuário ✅
- [ ] Funcionalidade ✅
- [ ] Metadados ✅
- [ ] Classificação Etária: Livre

**Tempo:** 1-3 dias

### App Store Review

**Checklist:**
- [ ] App Store Review Guidelines ✅
- [ ] Human Interface Guidelines ✅
- [ ] Privacidade ✅
- [ ] Performance ✅
- [ ] Classificação: 4+ (sem restrições)

**Tempo:** 24-48 horas

## Configurações de Privacidade

### Data Safety (Google Play)

```yaml
Dados Coletados:
  - Email (autenticação)
  - Nome (perfil)
  - Localização aproximada (cidade)
  - Mensagens (chat)

Compartilhamento:
  - Nenhum dado é compartilhado

Segurança:
  - Dados criptografados em trânsito
  - Dados criptografados em repouso
```

### Privacy Nutrition Label (App Store)

```yaml
Dados Vinculados ao Usuário:
  - Informações de Contato (email, nome)
  - Conteúdo do Usuário (livros, mensagens)
  - Localização (cidade)

Dados Não Vinculados:
  - Diagnósticos (crashes, analytics)
```

## Estratégia de Lançamento

### Soft Launch
1. **Beta Testing** (2 semanas)
   - TestFlight (iOS)
   - Internal Testing (Android)
   - 50-100 usuários beta

2. **Regional Launch** (1 mês)
   - Brasil apenas
   - Monitorar métricas
   - Coletar feedback

### Full Launch
1. **Marketing Prep**
   - Press kit
   - Social media
   - Influencers de leitura

2. **Launch Day**
   - Post em redes sociais
   - Newsletter
   - Comunidades de leitura

3. **Post-Launch**
   - Monitorar reviews
   - Responder feedback
   - Updates baseados em uso

## Métricas de Sucesso

### KPIs de Store
- Downloads/dia
- Rating médio (>4.0)
- Review sentiment
- Conversion rate (store → install)

### KPIs de Retenção
- Day 1/7/30 retention
- Time in app
- Feature adoption
- Monthly active users

## Troubleshooting

### Rejeições Comuns

**Google Play:**
- Metadata Policy: Descrição exagerada
- Content Policy: Conteúdo inadequado
- Privacy: Política de privacidade faltando

**App Store:**
- 2.1 App Completeness: App com bugs
- 4.3 Spam: Apps similares demais
- 5.1.1 Privacy: Dados sem justificativa

### Soluções Rápidas

```bash
# Rebuild limpo
flutter clean
flutter pub get
flutter build appbundle --release

# Verificar assinatura
jarsigner -verify -verbose -certs app-release.aab

# Análise do bundle
bundletool build-apks --bundle=app-release.aab --output=app.apks
```

O sucesso nas lojas depende de qualidade técnica + marketing efetivo! 📱
