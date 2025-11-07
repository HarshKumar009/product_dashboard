import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/app_router.dart';
import 'core/blocs/theme_cubit.dart';
import 'features/auth/presentation/blocs/auth_cubit.dart';
import 'features/product/presentation/blocs/product_cubit.dart';

import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ProductRepository>(
      create: (context) => ProductRepositoryImpl(
        remoteDataSource: ProductRemoteDataSourceImpl(client: http.Client()),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(),
          ),
          BlocProvider<ProductCubit>(
            create: (context) => ProductCubit(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'Product Dashboard',
              debugShowCheckedModeBanner: false,

              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorSchemeSeed: Colors.indigo,
                scaffoldBackgroundColor: Colors.grey[50],
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                  shadowColor: Colors.black,
                ),
                drawerTheme: const DrawerThemeData(
                  backgroundColor: Colors.white,
                ),
                navigationRailTheme: NavigationRailThemeData(
                  backgroundColor: Colors.white,
                  selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                  unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
                  selectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorSchemeSeed: Colors.indigo,
              ),

              themeMode: themeMode,
              routerConfig: AppRouter.createRouter(context),
            );
          },
        ),
      ),
    );
  }
}