import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NormalUserDashboard extends StatefulWidget {
  const NormalUserDashboard({super.key});

  @override
  State<NormalUserDashboard> createState() => _NormalUserDashboardState();
}

class _NormalUserDashboardState extends State<NormalUserDashboard> {
  final supabase = Supabase.instance.client;

  int totalEvents = 0;
  int upcomingEvents = 0;
  int totalAttendees = 0;

  List<Map<String, dynamic>> events = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final user = supabase.auth.currentUser;

      // creator events
      final eventData = await supabase
          .from('events')
          .select();

      totalEvents = eventData.length;

      final now = DateTime.now();

      upcomingEvents = eventData.where((event) {
        final date = DateTime.tryParse(
          event['event_date'].toString(),
        );

        return date != null && date.isAfter(now);
      }).length;

      events = List<Map<String, dynamic>>.from(eventData);

      // get ids of creator events
      // get ids of creator events
      final eventIds = eventData
          .map((e) => e['id'].toString())
          .toList();

      if (eventIds.isNotEmpty) {
        final registrations = await supabase
            .from('event_registrations')
            .select('id, event_id')
            .inFilter('event_id', eventIds);

        totalAttendees = registrations.length;
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<BarChartGroupData> buildChartData() {
    return events.asMap().entries.map((entry) {
      final index = entry.key;
      final event = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: 1,
          )
        ],
      );
    }).toList();
  }

  Widget statCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          /// top cards
          Row(
            children: [
              statCard(
                "Events",
                totalEvents.toString(),
                Icons.event,
              ),
              statCard(
                "Upcoming",
                upcomingEvents.toString(),
                Icons.calendar_today,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              statCard(
                "Attendees",
                totalAttendees.toString(),
                Icons.people,
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 250,
            child: BarChart(
  BarChartData(
    borderData: FlBorderData(show: false),
    gridData: FlGridData(show: false),

    titlesData: FlTitlesData(
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),

      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),

      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 70,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();

            if (index >= events.length) {
              return const SizedBox();
            }

            final event = events[index];

            final title =
                event['title'] ?? 'No Title';

            final date =
                event['event_date'] ?? '';

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    date.toString(),
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),

    barGroups: buildChartData(),
  ),
),
          ),
        ],
      ),
    );
  }
}