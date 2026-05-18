// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class CreatorHomePage extends StatefulWidget {
//   const CreatorHomePage({super.key});

//   @override
//   State<CreatorHomePage> createState() => _CreatorHomePageState();
// }

// class _CreatorHomePageState extends State<CreatorHomePage> {
//   final supabase = Supabase.instance.client;

//   final titleController = TextEditingController();
//   final descController = TextEditingController();
//   final locationController = TextEditingController();
//   final dateController = TextEditingController();

//   Future<void> createEvent() async {
//     final user = supabase.auth.currentUser;

//     await supabase.from('events').insert({
//       'title': titleController.text,
//       'description': descController.text,
//       'location': locationController.text,
//       'event_date': dateController.text,
//       'created_by': user!.id,
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Event Created")),
//     );

//     titleController.clear();
//     descController.clear();
//     locationController.clear();
//     dateController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Event Creator Dashboard")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: const InputDecoration(labelText: "Title"),
//             ),
//             TextField(
//               controller: descController,
//               decoration: const InputDecoration(labelText: "Description"),
//             ),
//             TextField(
//               controller: locationController,
//               decoration: const InputDecoration(labelText: "Location"),
//             ),
//             TextField(
//               controller: dateController,
//               decoration: const InputDecoration(labelText: "Event Date"),
//             ),
//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: createEvent,
//               child: const Text("Create Event"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'create_event_page.dart';
import 'login_page.dart';
import 'creator_dashboard.dart';

class CreatorHomePage extends StatefulWidget {
  const CreatorHomePage({super.key});

  @override
  State<CreatorHomePage> createState() => _CreatorHomePageState();
}

class _CreatorHomePageState extends State<CreatorHomePage> {
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

  Future<List<dynamic>> fetchMyEvents() async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('events')
        .select()
        .eq('created_by', user!.id)
        .order('id', ascending: false);

    return data;
  }

  Future<void> deleteEvent(int id) async {
    await supabase.from('events').delete().eq('id', id);
    setState(() {});
  }

Widget dashboard() {
  return const CreatorDashboard();
}

  Widget myEventsPage() {
    return FutureBuilder(
      future: fetchMyEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data as List<dynamic>;

        if (events.isEmpty) {
          return const Center(child: Text("No events created yet"));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(event['title']),
                subtitle: Text(event['location'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteEvent(event['id']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget getPage() {
    switch (selectedIndex) {
      case 0:
        return dashboard();
      case 1:
        return myEventsPage();
      case 2:
        return const CreateEventPage();
      default:
        return dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Creator Dashboard"),
        backgroundColor: Colors.green,
      ),

      // 📂 SIDEBAR
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: Text(
                  "Creator Menu",
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
              leading: const Icon(Icons.event),
              title: const Text("My Events"),
              onTap: () {
                setState(() => selectedIndex = 1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Create Event"),
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

      body: getPage(),
    );
  }
}