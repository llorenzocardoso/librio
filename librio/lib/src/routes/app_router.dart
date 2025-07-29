import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/routes/routes.dart';
import 'package:librio/src/shared/go_router_refresh_stream.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable:
        GoRouterRefreshStream(fb.FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = fb.FirebaseAuth.instance.currentUser != null;
      final goingToLogin = state.uri.toString() == AppRoutes.login ||
          state.uri.toString() == AppRoutes.signup ||
          state.uri.toString().startsWith(AppRoutes.resetPassword);
      if (!loggedIn && !goingToLogin) return AppRoutes.login;
      if (loggedIn && goingToLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookDetails,
        builder: (context, state) {
          final book = state.extra as Book;
          return BookDetailsScreen(book: book);
        },
      ),
      GoRoute(
        path: AppRoutes.addBook,
        builder: (context, state) => const AddBookScreen(),
      ),
      GoRoute(
        path: AppRoutes.editBook,
        builder: (context, state) {
          final book = state.extra as Book;
          return EditBookScreen(book: book);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.proposeExchange,
        builder: (context, state) {
          final book = state.extra as Book;
          return ProposeExchangeScreen(receiverBook: book);
        },
      ),
      GoRoute(
        path: AppRoutes.exchangeHistory,
        builder: (context, state) => const ExchangeHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.exchangeRequests,
        builder: (context, state) => const ExchangeRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.exchangeDetails,
        builder: (context, state) {
          final exchange = state.extra as Exchange;
          return ExchangeDetailsScreen(exchange: exchange);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatList,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final otherUserName = state.uri.queryParameters['otherUserName'];
          return ChatScreen(
            chatId: chatId,
            otherUserName: otherUserName,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationSettings,
        builder: (context, state) => const LocationSettingsScreen(),
      ),
    ],
  );
}
