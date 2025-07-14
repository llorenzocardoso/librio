# ⭐ Sistema de Avaliações

## Visão Geral

O sistema de avaliações permite que usuários avaliem uns aos outros após completarem trocas de livros, criando um sistema de reputação confiável na plataforma.

## Estrutura de Dados

### Rating Entity

```dart
class Rating {
  final String id;
  final String exchangeId;
  final String raterId;       // Quem avalia
  final String ratedUserId;   // Quem é avaliado
  final int rating;           // 1-5 estrelas
  final String? comment;      // Comentário opcional
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.exchangeId,
    required this.raterId,
    required this.ratedUserId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
```

## Fluxo de Avaliação

### 1. Trigger da Avaliação
- Executado após ambos confirmarem conclusão da troca
- Cada participante avalia o outro
- Avaliação é opcional mas incentivada

### 2. Interface de Avaliação

```dart
class RatingScreen extends StatefulWidget {
  final String exchangeId;
  final String ratedUserId;
  final String ratedUserName;

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliar ${widget.ratedUserName}'),
      ),
      body: Column(
        children: [
          _buildStarRating(),
          _buildCommentField(),
          _buildSubmitButton(),
        ],
      ),
    );
  }
}
```

### 3. Sistema de Estrelas

```dart
Widget _buildStarRating() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (index) {
      return IconButton(
        icon: Icon(
          index < _selectedRating
            ? Icons.star
            : Icons.star_border,
          color: Colors.amber,
          size: 40,
        ),
        onPressed: () {
          setState(() {
            _selectedRating = index + 1;
          });
        },
      );
    }),
  );
}
```

## Repository Implementation

### RatingRepository

```dart
abstract class RatingRepository {
  Future<void> addRating(Rating rating);
  Future<List<Rating>> getUserRatings(String userId);
  Future<double> getUserAverageRating(String userId);
  Future<bool> hasRatedExchange(String exchangeId, String raterId);
}

class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addRating(Rating rating) async {
    await _firestore
        .collection('ratings')
        .add(rating.toFirestore());
  }

  @override
  Future<List<Rating>> getUserRatings(String userId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('ratedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Rating.fromFirestore(doc))
        .toList();
  }

  @override
  Future<double> getUserAverageRating(String userId) async {
    final ratings = await getUserRatings(userId);
    if (ratings.isEmpty) return 0.0;

    final sum = ratings.fold(0, (sum, rating) => sum + rating.rating);
    return sum / ratings.length;
  }
}
```

## Use Cases

### AddRatingUseCase

```dart
class AddRatingUseCase {
  final RatingRepository _repository;

  AddRatingUseCase(this._repository);

  Future<void> call(Rating rating) async {
    // Validações
    if (rating.rating < 1 || rating.rating > 5) {
      throw Exception('Rating deve estar entre 1 e 5');
    }

    if (rating.raterId == rating.ratedUserId) {
      throw Exception('Usuário não pode avaliar a si mesmo');
    }

    // Verificar se já avaliou esta troca
    final hasRated = await _repository.hasRatedExchange(
      rating.exchangeId,
      rating.raterId
    );

    if (hasRated) {
      throw Exception('Usuário já avaliou esta troca');
    }

    await _repository.addRating(rating);
  }
}
```

## Exibição de Avaliações

### No Perfil do Usuário

```dart
class UserRatingDisplay extends StatelessWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: context.read<RatingRepository>()
          .getUserAverageRating(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final average = snapshot.data!;
        return Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < average.round()
                  ? Icons.star
                  : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
            SizedBox(width: 8),
            Text('${average.toStringAsFixed(1)} (${_totalRatings} avaliações)'),
          ],
        );
      },
    );
  }
}
```

### Lista de Avaliações

```dart
class RatingsList extends StatelessWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Rating>>(
      future: context.read<RatingRepository>()
          .getUserRatings(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final ratings = snapshot.data!;
        return ListView.builder(
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final rating = ratings[index];
            return RatingCard(rating: rating);
          },
        );
      },
    );
  }
}

class RatingCard extends StatelessWidget {
  final Rating rating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.rating
                      ? Icons.star
                      : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
                Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy').format(rating.createdAt),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            if (rating.comment != null) ...[
              SizedBox(height: 8),
              Text(rating.comment!),
            ],
          ],
        ),
      ),
    );
  }
}
```

## Firestore Rules

```javascript
// Regras para ratings
match /ratings/{ratingId} {
  // Leitura: usuário pode ver avaliações que recebeu
  allow read: if request.auth != null &&
              request.auth.uid == resource.data.ratedUserId;

  // Criação: apenas quem participou da troca pode avaliar
  allow create: if request.auth != null &&
                request.auth.uid == request.resource.data.raterId &&
                request.auth.uid != request.resource.data.ratedUserId &&
                // Verificar se o usuário participou da troca
                exists(/databases/$(database)/documents/exchanges/$(request.resource.data.exchangeId)) &&
                (get(/databases/$(database)/documents/exchanges/$(request.resource.data.exchangeId)).data.proposerId == request.auth.uid ||
                 get(/databases/$(database)/documents/exchanges/$(request.resource.data.exchangeId)).data.ownerId == request.auth.uid);

  // Não permite atualização ou deleção
  allow update, delete: if false;
}
```

## Integração com Sistema de Trocas

### Após Conclusão da Troca

```dart
class ExchangeRepositoryImpl {
  Future<void> confirmExchangeCompletion(
    String exchangeId,
    String userId
  ) async {
    // ... lógica existente ...

    // Após ambos confirmarem
    if (exchange.proposerConfirmed && exchange.ownerConfirmed) {
      // Atualizar status
      await _updateExchangeStatus(exchangeId, 'completed');

      // Sugerir avaliação
      await _promptForRating(exchange);
    }
  }

  Future<void> _promptForRating(Exchange exchange) async {
    // Enviar notificação para ambos usuários avaliarem
    final notification1 = AppNotification(
      userId: exchange.proposerId,
      type: 'rating_request',
      title: 'Avalie sua troca',
      message: 'Como foi sua experiência com ${exchange.ownerName}?',
      data: {
        'exchangeId': exchange.id,
        'ratedUserId': exchange.ownerId,
      },
    );

    final notification2 = AppNotification(
      userId: exchange.ownerId,
      type: 'rating_request',
      title: 'Avalie sua troca',
      message: 'Como foi sua experiência com ${exchange.proposerName}?',
      data: {
        'exchangeId': exchange.id,
        'ratedUserId': exchange.proposerId,
      },
    );

    // Enviar notificações
  }
}
```

## Métricas e Analytics

### Estatísticas do Sistema

```dart
class RatingAnalytics {
  static Future<Map<String, dynamic>> getSystemStats() async {
    final firestore = FirebaseFirestore.instance;

    // Total de avaliações
    final totalRatings = await firestore
        .collection('ratings')
        .get()
        .then((snapshot) => snapshot.size);

    // Média geral
    final allRatings = await firestore
        .collection('ratings')
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => doc.data()['rating'] as int)
            .toList());

    final overallAverage = allRatings.isEmpty
        ? 0.0
        : allRatings.reduce((a, b) => a + b) / allRatings.length;

    // Distribuição por estrelas
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = allRatings.where((r) => r == i).length;
    }

    return {
      'totalRatings': totalRatings,
      'overallAverage': overallAverage,
      'distribution': distribution,
      'participationRate': await _getParticipationRate(),
    };
  }
}
```

## Benefícios do Sistema

### Para Usuários
- ✅ **Confiança**: Sistema de reputação transparente
- ✅ **Qualidade**: Incentiva bom comportamento
- ✅ **Feedback**: Melhoria contínua da experiência

### Para a Plataforma
- ✅ **Moderação**: Identificação de usuários problemáticos
- ✅ **Qualidade**: Melhoria geral das trocas
- ✅ **Retenção**: Usuários bem avaliados tendem a ficar

## Futuras Melhorias

### Funcionalidades Avançadas
- [ ] **Badges**: Conquistas baseadas em avaliações
- [ ] **Filtros**: Buscar apenas usuários bem avaliados
- [ ] **Relatórios**: Moderação automática de usuários
- [ ] **Incentivos**: Recompensas por boas avaliações

### Análises
- [ ] **Correlação**: Rating vs. sucesso de trocas
- [ ] **Previsão**: Identificar trocas de risco
- [ ] **Segmentação**: Perfis de usuários por rating

O sistema de avaliações é essencial para construir confiança e qualidade na plataforma Librio! ⭐
