// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'event_regestration_page.dart';
// import 'normal_user_dashboard.dart';

// class UserHomePage extends StatefulWidget {
//   const UserHomePage({super.key});

//   @override
//   State<UserHomePage> createState() => _UserHomePageState();
// }

// class _UserHomePageState extends State<UserHomePage> {
//   final supabase = Supabase.instance.client;

//   int selectedIndex = 0;

//   final pages = [
//     const NormalUserDashboard(),
//   ];

//   void logout() async {
//     await supabase.auth.signOut();
//     if (mounted) {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Event App"),
//         backgroundColor: Colors.blue,
//       ),

//       /// SIDEBAR
//       drawer: Drawer(
//         child: Column(
//           children: [
//             const UserAccountsDrawerHeader(
//               accountName: Text("User"),
//               accountEmail: Text("user@example.com"),
//               currentAccountPicture: CircleAvatar(
//                 child: Icon(Icons.person),
//               ),
//             ),

//             ListTile(
//               leading: const Icon(Icons.dashboard),
//               title: const Text("Dashboard"),
//               onTap: () {
//                 setState(() => selectedIndex = 0);
//                 Navigator.pop(context);
//               },
//             ),

//             ListTile(
//               leading: const Icon(Icons.event),
//               title: const Text("Available Events"),
//               onTap: () {
//                 setState(() => selectedIndex = 1);
//                 Navigator.pop(context);
//               },
//             ),

//             ListTile(
//               leading: const Icon(Icons.check_circle),
//               title: const Text("Registered Events"),
//               onTap: () {
//                 setState(() => selectedIndex = 2);
//                 Navigator.pop(context);
//               },
//             ),

//             const Spacer(),

//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text("Logout"),
//               onTap: logout,
//             ),
//           ],
//         ),
//       ),

//       body: pages[selectedIndex],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'event_regestration_page.dart';
import 'normal_user_dashboard.dart';
import 'available_events_page.dart';
import 'registered_events_page.dart';
import 'login_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final supabase = Supabase.instance.client;

  int selectedIndex = 0;

  late final List<Widget> pages = [
    const NormalUserDashboard(),
    const AvailableEventsPage(),
    const RegisteredEventsPage(),
  ];

  Future<void> logout() async {
  await supabase.auth.signOut();

  if (!mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event App"),
        backgroundColor: Colors.blue,
      ),

      /// SIDEBAR
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("User"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              selected: selectedIndex == 0,
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Available Events"),
              selected: selectedIndex == 1,
              onTap: () {
                setState(() => selectedIndex = 1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text("Registered Events"),
              selected: selectedIndex == 2,
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

      body: pages[selectedIndex],
    );
  }
}