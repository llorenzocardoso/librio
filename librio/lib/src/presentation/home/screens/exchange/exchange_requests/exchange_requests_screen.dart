import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'widgets/widgets.dart';

class ExchangeRequestsScreen extends StatefulWidget {
  const ExchangeRequestsScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
}

class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ExchangeRequestsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    viewModel = ExchangeRequestsViewModel();
    viewModel.addListener(() => setState(() {}));
    viewModel.loadExchanges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildExchangeCard(Exchange exchange) {
    final currentUserId = viewModel.getCurrentUserId()!;

    return ExchangeRequestCard(
      exchange: exchange,
      currentUserId: currentUserId,
      onAccept: () => viewModel.updateExchangeStatus(
        exchange.id,
        ExchangeStatus.accepted,
        context,
      ),
      onReject: () => viewModel.updateExchangeStatus(
        exchange.id,
        ExchangeStatus.rejected,
        context,
      ),
      onTap: () => viewModel.navigateToExchangeDetails(context, exchange),
    );
  }

  Widget _buildOngoingExchangeCard(Exchange exchange) {
    final currentUserId = viewModel.getCurrentUserId()!;

    return OngoingExchangeCard(
      exchange: exchange,
      currentUserId: currentUserId,
      onMarkAsCompleted: () =>
          viewModel.markAsCompleted(exchange.id, context, exchange),
      onTap: () => viewModel.navigateToExchangeDetails(context, exchange),
    );
  }

  Widget _buildTabContent(List<Exchange> exchanges, {bool isOngoing = false}) {
    if (exchanges.isEmpty) {
      return Center(
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
            Text(
              isOngoing
                  ? 'Nenhuma troca em andamento'
                  : 'Nenhuma troca encontrada',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exchanges.length,
            itemBuilder: (context, index) {
              final exchange = exchanges[index];
              return isOngoing
                  ? _buildOngoingExchangeCard(exchange)
                  : _buildExchangeCard(exchange);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => viewModel.navigateBack(context),
        ),
        title: const Text(
          'Minhas Trocas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () => viewModel.navigateToExchangeHistory(context),
            tooltip: 'Histórico de trocas',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF176FF1),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF176FF1),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Pendente'),
            Tab(text: 'Em Andamento'),
            Tab(text: 'Recusada'),
          ],
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
                        'Erro ao carregar trocas',
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
                        onPressed: viewModel.loadExchanges,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(viewModel.pendingExchanges),
                    _buildTabContent(viewModel.ongoingExchanges,
                        isOngoing: true),
                    _buildTabContent(viewModel.rejectedExchanges),
                  ],
                ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}
