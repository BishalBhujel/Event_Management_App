import 'package:event_management_app/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'role_router.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hrdtxfzajbfnfpfkriyp.supabase.co',
    anonKey: 'sb_publishable_6urQRhBZXGWBvj52J-Cudw_3EA7gq_d',
  );

  final session = Supabase.instance.client.auth.currentSession;
  runApp(MyApp(isLoggedIn: session != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn ? const RoleRouter() : const LoginPage(),
    );
  }
}