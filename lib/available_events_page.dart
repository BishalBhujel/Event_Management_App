import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'event_regestration_page.dart';

class AvailableEventsPage extends StatefulWidget {
  const AvailableEventsPage({super.key});

  @override
  State<AvailableEventsPage> createState() => _AvailableEventsPageState();
}

class _AvailableEventsPageState extends State<AvailableEventsPage> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = fetchEvents();
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
  final user = supabase.auth.currentUser;

  // 1. Get all events
  final eventsResponse = await supabase
      .from('events')
      .select()
      .order('event_date', ascending: true);

  // 2. Get user registrations
  final registrationResponse = await supabase
      .from('event_registrations')
      .select('event_id')
      .eq('user_id', user!.id);

  // 3. Convert registered event IDs into a Set
  final registeredIds = registrationResponse
      .map((e) => e['event_id'].toString())
      .toSet();

  // 4. Filter OUT registered events in Dart
  final filteredEvents = (eventsResponse as List).where((event) {
    return !registeredIds.contains(event['id'].toString());
  }).toList();

  return List<Map<String, dynamic>>.from(filteredEvents);
}

  Future<void> registerForEvent(String eventId) async {
    final user = supabase.auth.currentUser;

    await supabase.from('event_registrations').insert({
      'event_id': eventId,
      'user_id': user!.id,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registered successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;

        if (events.isEmpty) {
          return const Center(child: Text("No events available"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
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

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          registerForEvent(event['id'].toString());
                        },
                        child: const Text("Register"),
                      ),
                    ),
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