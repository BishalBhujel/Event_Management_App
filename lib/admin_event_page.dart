import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final data = await supabase
          .from('events')
          .select('*, users!events_created_by_fkey(email)')
          .order('event_date', ascending: true);

      events = List<Map<String, dynamic>>.from(data);

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint("Load error: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> deleteEvent(Map<String, dynamic> event) async {
    final id = event['id'].toString();

    final res = await supabase
        .from('events')
        .delete()
        .eq('id', id)
        .select();

    if (res.isNotEmpty) {
      setState(() {
        events.removeWhere((e) => e['id'].toString() == id);
      });
    }
  }

  Widget eventCard(Map<String, dynamic> event) {
    final title = event['title'] ?? 'No Title';
    final date = event['event_date'] ?? '';
    final location = event['location'] ?? 'No location';

    // 👇 creator info from join
    final creatorEmail =
        event['users']?['email'] ?? 'Unknown user';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// EVENT INFO
            Row(
              children: [
                const Icon(Icons.event, color: Colors.blue),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await deleteEvent(event);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text("📅 Date: $date"),
            Text("📍 Location: $location"),

            const SizedBox(height: 6),

            /// CREATOR INFO 👇
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Created by: $creatorEmail",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Events"),
        backgroundColor: Colors.green[50],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Center(child: Text("No events found"))
              : RefreshIndicator(
                  onRefresh: loadEvents,
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return eventCard(events[index]);
                    },
                  ),
                ),
    );
  }
}