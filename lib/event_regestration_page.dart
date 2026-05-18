import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRegistrationPage extends StatefulWidget {
  const EventRegistrationPage({super.key});

  @override
  State<EventRegistrationPage> createState() =>
      _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchEvents() async {
    final data = await supabase
        .from('events')
        .select()
        .order('id', ascending: false);

    return data;
  }

  Future<void> registerForEvent(int eventId) async {
    final user = supabase.auth.currentUser;

    try {
      await supabase.from('event_registrations').insert({
        'event_id': eventId,
        'user_id': user!.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register for Events"),
      ),
      body: FutureBuilder(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data as List<dynamic>;

          if (events.isEmpty) {
            return const Center(child: Text("No events available"));
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
                  trailing: ElevatedButton(
                    onPressed: () =>
                        registerForEvent(event['id']),
                    child: const Text("Register"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}