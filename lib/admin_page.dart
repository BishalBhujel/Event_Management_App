import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import 'admin_dashboard.dart';
import 'admin_event_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final supabase = Supabase.instance.client;

  int selectedIndex = 0;

  Future<void> logout() async {
    await supabase.auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget getPage() {
    switch (selectedIndex) {
      case 0:
        return const AdminDashboard();
      case 1:
        return buildUsersPage();
      case 2:
        return const AdminEventsPage();
      default:
        return const Center(child: Text("Page"));
    }
  }

  Widget buildUsersPage() {
  final currentUser = supabase.auth.currentUser;

  return FutureBuilder(
    future: supabase.from('users').select(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data == null) {
        return const Center(child: Text("No users found"));
      }

      final users = snapshot.data as List<dynamic>;

      // remove current user
      final filteredUsers = users.where((u) {
        return u['id'] != currentUser?.id;
      }).toList();

      return StatefulBuilder(
        builder: (context, setState) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];

              final String role = user['role'] ?? 'normal_user';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          (user['email'] ?? '?')[0].toUpperCase(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// USER INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['email'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Role: $role",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ROLE CONTROL
                      if (role != 'admin')
                        DropdownButton<String>(
                          value: role,
                          items: const [
                            DropdownMenuItem(
                              value: 'normal_user',
                              child: Text('Normal User'),
                            ),
                            DropdownMenuItem(
                              value: 'event_creator',
                              child: Text('Event Creator'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (newRole) async {
                            if (newRole == null) return;

                            final res = await supabase
                                .from('users')
                                .update({'role': newRole})
                                .eq('id', user['id'])
                                .select();

                            if (res.isEmpty) {
                              debugPrint("Update failed (check RLS policies)");
                            }

                            setState(() {
                              filteredUsers[index]['role'] = newRole;
                            });
                          },
                        )
                      else
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.red,
      ),

      // 🧠 SIDEBAR START
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Center(
                child: Text(
                  "Admin Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Users"),
              onTap: () {
                setState(() => selectedIndex = 1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Events"),
              onTap: () {
                setState(() => selectedIndex = 2);
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),

      // 🧠 MAIN CONTENT
      body: getPage(),
    );
  }
}