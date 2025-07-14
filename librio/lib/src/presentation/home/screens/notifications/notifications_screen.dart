import 'package:flutter/material.dart';
import 'widgets/widgets.dart';
import 'notifications_viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = NotificationsViewModelImpl();
    viewModel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notificações',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return _buildErrorState();
    }

    return _buildNotificationsList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar notificações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error ?? 'Erro desconhecido',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewModel.refreshNotifications(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final data = viewModel.notificationsData;
    if (data == null || !data.hasNotifications) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.pendingRatings.isNotEmpty) ...[
            _buildSectionHeader('Avaliações pendentes'),
            ...data.pendingRatings.map((exchange) => PendingRatingCard(
                  exchange: exchange,
                  onTap: () => viewModel.navigateToRating(context, exchange),
                )),
            const SizedBox(height: 24),
          ],

          if (data.pendingExchanges.isNotEmpty) ...[
            _buildSectionHeader('Novas propostas'),
            ...data.pendingExchanges
                .map((exchange) => PendingExchangeNotification(
                      exchange: exchange,
                      onTap: () => viewModel.navigateToExchangeDetails(
                          context, exchange),
                    )),
            const SizedBox(height: 24),
          ],

          if (data.recentAcceptedExchanges.isNotEmpty) ...[
            _buildSectionHeader('Propostas aceitas'),
            ...data.recentAcceptedExchanges
                .map((exchange) => AcceptedExchangeNotification(
                      exchange: exchange,
                      onTap: () =>
                          viewModel.startChatAfterAccepted(context, exchange),
                    )),
            const SizedBox(height: 24),
          ],

          if (data.recentExchanges.isNotEmpty) ...[
            _buildSectionHeader('Atividade recente'),
            ...data.recentExchanges
                .map((exchange) => RecentExchangeNotification(
                      exchange: exchange,
                      onTap: () => viewModel.navigateToExchangeDetails(
                          context, exchange),
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você está em dia! 📚',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
