import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_home_page.dart';
import 'creator_home_page.dart';
import 'login_page.dart';
import 'admin_page.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  Future<String?> getUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return null;

    final data = await Supabase.instance.client
        .from('users')
        .select('role')
        .eq('id', user.id)
        .single();

    return data['role'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final role = snapshot.data;

        if (role=='admin') {
          return const AdminPage();
        } else if (role == 'event_creator') {
          return const CreatorHomePage();
        } else {
          return const UserHomePage();
        }
      },
    );
  }
}