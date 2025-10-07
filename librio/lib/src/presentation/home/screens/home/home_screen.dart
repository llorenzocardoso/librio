import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel viewmodel;

  @override
  void initState() {
    super.initState();
    viewmodel = HomeViewModel();
  }

  @override
  void dispose() {
    viewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewmodel,
      builder: (context, child) {
        final books = viewmodel.books;
        final isLoading = viewmodel.isLoading;
        final error = viewmodel.error;

        final categories = viewmodel.availableCategories;
        final selectedCategoryIndex =
            categories.indexOf(viewmodel.selectedCategory);

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: viewmodel.refresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Librio',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  viewmodel.navigateToLocationSettings(context);
                                },
                                icon: Icon(
                                  viewmodel.locationEnabled
                                      ? Icons.location_on
                                      : Icons.location_off,
                                  color: viewmodel.locationEnabled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                tooltip: viewmodel.locationEnabled
                                    ? 'Localização ativada'
                                    : 'Ativar localização',
                              ),
                              NotificationIconWithBadge(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SearchBarWidget(
                    onChanged: (query) => viewmodel.searchBooks(query),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CategoryFilter(
                    categories: categories,
                    selectedIndex: selectedCategoryIndex,
                    onSelected: (idx) {
                      final selectedCategory = categories[idx];
                      viewmodel.filterByCategory(selectedCategory);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Livros Disponíveis para Troca',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (viewmodel.locationEnabled) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Próximos a você',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        if (viewmodel.locationEnabled &&
                            viewmodel.currentLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Localização: ${viewmodel.currentLocation}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (viewmodel.selectedCategory != 'Todos' ||
                            viewmodel.searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (viewmodel.selectedCategory != 'Todos')
                                Chip(
                                  label: Text(
                                    'Categoria: ${viewmodel.selectedCategory}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.blue.shade50,
                                  side: BorderSide(color: Colors.blue.shade200),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () =>
                                      viewmodel.filterByCategory('Todos'),
                                ),
                              if (viewmodel.searchQuery.isNotEmpty)
                                Chip(
                                  label: Text(
                                    'Busca: "${viewmodel.searchQuery}"',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: Colors.green.shade50,
                                  side:
                                      BorderSide(color: Colors.green.shade200),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  onDeleted: () => viewmodel.searchBooks(''),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        if (viewmodel.locationEnabled && books.isNotEmpty)
                          Text(
                            'Encontrados ${books.length} livro${books.length != 1 ? 's' : ''} próximos a você',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        else if (viewmodel.selectedCategory != 'Todos')
                          Text(
                            'Encontrados ${books.length} livro${books.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (error != null)
                  _buildErrorState()
                else if (!viewmodel.locationPreferencesLoaded)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!viewmodel.locationEnabled)
                  _buildLocationRequiredState()
                else if (books.isEmpty)
                  _buildEmptyState()
                else
                  _buildBooksGrid(books),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => viewmodel.navigateToAddBook(context),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: SvgPicture.asset(
              'assets/icons/add_icon.svg',
              width: 24,
              height: 24,
            ),
          ),
          bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar livros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewmodel.error ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewmodel.refresh(),
              child: const Text('Tentar novamente'),
            ),
            if (viewmodel.error?.contains('permissão') == true ||
                viewmodel.error?.contains('permission') == true)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao fazer logout: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Fazer Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              viewmodel.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.book_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              viewmodel.searchQuery.isNotEmpty
                  ? 'Nenhum livro encontrado'
                  : 'Nenhum livro disponível',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewmodel.searchQuery.isNotEmpty
                  ? 'Tente pesquisar com outros termos'
                  : 'Seja o primeiro a adicionar um livro!',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewmodel.navigateToAddBook(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar livro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRequiredState() {
    return SliverFillRemaining(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 200,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off,
                size: 80,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ative a Localização',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Para encontrar livros próximos a você e fazer trocas viáveis, precisamos da sua localização.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sem localização, você pode ver livros de pessoas muito distantes, tornando as trocas impraticáveis.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => viewmodel.navigateToLocationSettings(context),
                icon: const Icon(Icons.location_on),
                label: const Text('Configurar Localização'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: viewmodel.isLoadingLocation
                    ? null
                    : () async {
                        try {
                          await viewmodel.activateLocationQuickly();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Localização ativada com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Erro ao ativar localização: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                icon: viewmodel.isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.settings),
                label: Text(viewmodel.isLoadingLocation
                    ? 'Obtendo localização...'
                    : 'Ativar Rapidamente'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Por que precisamos da localização?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Encontrar livros próximos a você\n'
                      '• Evitar propostas de troca inviáveis\n'
                      '• Melhorar a experiência de troca\n'
                      '• Economizar tempo e deslocamento',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBooksGrid(List books) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books[index];
            return BookCard(
              book: book,
              onTap: () => viewmodel.navigateToBookDetails(
                context,
                book,
              ),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
