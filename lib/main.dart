import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendify/services/auth_service.dart';
import 'package:vendify/services/product_service.dart';
import 'package:vendify/services/sale_service.dart';
import 'theme.dart';
import 'nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..init()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => SaleService()),
      ],
      child: MaterialApp.router(
        title: 'Vendify POS',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
