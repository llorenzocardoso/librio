import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel viewmodel;
  int selectedCategoryIndex = 0;
  int _selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    viewmodel = HomeViewModel();
    viewmodel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    viewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = viewmodel.isLoading;
    final books = viewmodel.books;
    final categories = books.map((b) => b.genre).toSet().toList()..sort();
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewmodel.refresh,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
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
                            IconButton(
                              icon: SvgPicture.asset(
                                  'assets/icons/notification_icon.svg',
                                  width: 32,
                                  height: 32),
                              onPressed: () {
                                // Implement notification functionality
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Campo de busca customizado
                  const SliverToBoxAdapter(
                    child: SearchBarWidget(),
                  ),
                  // Filtro de categorias
                  SliverToBoxAdapter(
                    child: CategoryFilter(
                      categories: categories,
                      selectedIndex: selectedCategoryIndex,
                      onSelected: (idx) =>
                          setState(() => selectedCategoryIndex = idx),
                    ),
                  ),

                  // Título da seção
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Livros Disponíveis para Troca',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Grid de livros
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                            onTap: () => context.push('/details', extra: book),
                          );
                        },
                        childCount: books.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewmodel.navigateToAddBook(context),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: SvgPicture.asset('assets/icons/add_icon.svg',
            width: 24, height: 24),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedBottomIndex,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SvgPicture.asset('assets/icons/home_icon.svg',
                  width: 24, height: 24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SvgPicture.asset('assets/icons/exchange_icon.svg',
                  width: 24, height: 24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SvgPicture.asset('assets/icons/chat_icon.svg',
                  width: 24, height: 24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SvgPicture.asset('assets/icons/profile_icon.svg',
                  width: 24, height: 24),
            ),
            label: '',
          ),
        ],
        onTap: (index) {
          setState(() => _selectedBottomIndex = index);
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 3:
              context.push('/profile');
              break;
            // Add other cases if needed for other tabs
            default:
              break;
          }
        },
      ),
    );
  }
}
