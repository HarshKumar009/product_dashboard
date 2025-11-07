import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:product_dashboard/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:product_dashboard/features/auth/presentation/blocs/auth_state.dart';
import 'package:product_dashboard/features/auth/presentation/pages/login_page.dart';
import 'package:product_dashboard/features/product/presentation/widgets/main_layout.dart';
import 'package:product_dashboard/features/settings/presentation/pages/settings_page.dart';
import '../features/product/presentation/pages/product_list_page.dart';
import '../features/product/presentation/pages/product_details_page.dart';


class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return GoRouter(
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: <RouteBase>[
            GoRoute(path: '/', builder: (context, state) => const ProductListPage()),
            GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
            GoRoute(
              path: '/product/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ProductDetailsPage(productId: int.parse(id));
              },
            ),
          ],
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = authCubit.state is Authenticated;
        final bool loggingIn = state.matchedLocation == '/login';

        if (!loggedIn) {
          return loggingIn ? null : '/login';
        }

        if (loggingIn) {
          return '/';
        }

        return null;
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}