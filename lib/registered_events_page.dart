import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisteredEventsPage extends StatefulWidget {
  const RegisteredEventsPage({super.key});

  @override
  State<RegisteredEventsPage> createState() => _RegisteredEventsPageState();
}

class _RegisteredEventsPageState extends State<RegisteredEventsPage> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> registeredFuture;

  @override
  void initState() {
    super.initState();
    registeredFuture = fetchRegisteredEvents();
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredEvents() async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('event_registrations')
        .select('''
          id,
          events (
            id,
            title,
            description,
            location,
            event_date
          )
        ''')
        .eq('user_id', user!.id);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: registeredFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final registrations = snapshot.data!;

        if (registrations.isEmpty) {
          return const Center(child: Text("No registered events"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: registrations.length,
          itemBuilder: (context, index) {
            final event = registrations[index]['events'];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(event['description'] ?? ''),
                    const SizedBox(height: 6),
                    Text("📍 ${event['location'] ?? ''}"),
                    Text("📅 ${event['event_date'] ?? ''}"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}