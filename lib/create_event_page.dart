import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final supabase = Supabase.instance.client;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();

  Future<void> createEvent() async {
    final user = supabase.auth.currentUser;

    await supabase.from('events').insert({
      'title': titleController.text,
      'description': descController.text,
      'location': locationController.text,
      'event_date': dateController.text,
      'created_by': user!.id,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event Created")),
    );

    titleController.clear();
    descController.clear();
    locationController.clear();
    dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Creator Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Event Date"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: createEvent,
              child: const Text("Create Event"),
            )
          ],
        ),
      ),
    );
  }
}