import 'package:go_router/go_router.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/shared/go_router_refresh_stream.dart';
import 'package:librio/src/domain/entities/book.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable:
        GoRouterRefreshStream(fb.FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = fb.FirebaseAuth.instance.currentUser != null;
      final goingToLogin =
          state.uri.toString() == '/login' || state.uri.toString() == '/signup';
      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) {
          final book = state.extra as Book;
          return BookDetailsScreen(book: book);
        },
      ),
      GoRoute(
        path: '/add_book',
        builder: (context, state) => const AddBookScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    // Optional: Redirect logic (e.g., for authentication)
    // redirect: (context, state) async {
    //   // Implement your auth logic here
    //   // final authService = Provider.of<AuthService>(context, listen: false);
    //   // final isLoggedIn = await authService.isLoggedIn();
    //   // if (!isLoggedIn && state.location != '/auth') {
    //   //   return '/auth';
    //   // }
    //   return null;
    // },
  );
}
