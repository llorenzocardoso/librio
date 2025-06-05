import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'package:intl/intl.dart';

class ExchangeHistoryScreen extends StatefulWidget {
  const ExchangeHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeHistoryScreen> createState() => _ExchangeHistoryScreenState();
}

class _ExchangeHistoryScreenState extends State<ExchangeHistoryScreen> {
  late ExchangeHistoryViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ExchangeHistoryViewModel();
    viewModel.addListener(() => setState(() {}));
    viewModel.loadExchanges();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildExchangeCard(Exchange exchange) {
    final bool isCompleted = exchange.status == ExchangeStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header com status
          Row(
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(exchange.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(exchange.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(exchange.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Livros da troca
          Row(
            children: [
              // Livro oferecido (esquerda)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 85,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: exchange.proposerBookImageUrl.isNotEmpty
                            ? Image.network(
                                exchange.proposerBookImageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.book,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Seta
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Colors.grey,
                ),
              ),

              // Livro desejado (direita)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 85,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: exchange.receiverBookImageUrl.isNotEmpty
                            ? Image.network(
                                exchange.receiverBookImageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.book,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Avatares dos usuários e status de verificação
          Column(
            children: [
              // Linha com avatares e sistema de conexão
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar do usuário da esquerda
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Sistema de linhas e ícone central (sem texto)
                  Expanded(
                    child: _buildConnectionSystem(exchange),
                  ),

                  const SizedBox(width: 16),

                  // Avatar do usuário da direita
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Texto "Troca Verificada" separado
              if (isCompleted &&
                  exchange.proposerConfirmed &&
                  exchange.receiverConfirmed) ...[
                const SizedBox(height: 8),
                Text(
                  'Troca Verificada',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          // Botão de avaliação para trocas concluídas não avaliadas
          if (viewModel.canUserRate(exchange)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => viewModel.navigateToRating(context, exchange),
                icon: const Icon(Icons.star, size: 16),
                label: const Text(
                  'Avaliar usuário',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionSystem(Exchange exchange) {
    final bool isCurrentUserProposer =
        exchange.proposerId == viewModel.getCurrentUserId();
    final bool leftUserConfirmed = isCurrentUserProposer
        ? exchange.proposerConfirmed
        : exchange.receiverConfirmed;
    final bool rightUserConfirmed = isCurrentUserProposer
        ? exchange.receiverConfirmed
        : exchange.proposerConfirmed;
    final bool bothConfirmed =
        exchange.proposerConfirmed && exchange.receiverConfirmed;
    final bool isCompleted = exchange.status == ExchangeStatus.completed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Linha esquerda conectando ao ícone
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: leftUserConfirmed
                  ? const Color(0xFFC3F15A)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),

        // Ícone central (sem espaçamento para conectar diretamente)
        SvgPicture.asset(
          'assets/icons/checkbox_verification.svg',
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            bothConfirmed && isCompleted
                ? const Color(0xFFC3F15A)
                : Colors.grey[400]!,
            BlendMode.srcIn,
          ),
        ),

        // Linha direita conectando ao ícone
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: rightUserConfirmed
                  ? const Color(0xFFC3F15A)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.pending:
        return Colors.orange;
      case ExchangeStatus.accepted:
        return Colors.blue;
      case ExchangeStatus.completed:
        return Colors.green;
      case ExchangeStatus.rejected:
        return Colors.red;
      case ExchangeStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.pending:
        return 'Troca pendente';
      case ExchangeStatus.accepted:
        return 'Troca aceita';
      case ExchangeStatus.completed:
        return 'Troca concluída';
      case ExchangeStatus.rejected:
        return 'Troca recusada';
      case ExchangeStatus.cancelled:
        return 'Troca cancelada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => viewModel.navigateBack(context),
        ),
        title: const Text(
          'Histórico de trocas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Erro ao carregar histórico',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        viewModel.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: viewModel.refresh,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : viewModel.exchanges.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/exchange_icon.svg',
                            width: 64,
                            height: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma troca encontrada',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Suas trocas aparecerão aqui',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: viewModel.refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.exchanges.length,
                        itemBuilder: (context, index) {
                          final exchange = viewModel.exchanges[index];
                          return _buildExchangeCard(exchange);
                        },
                      ),
                    ),
    );
  }
}
