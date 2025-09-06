import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const InsightsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final results = data['results'] as List<dynamic>? ?? [];
    final topic = data['topic'] ?? "Insights";

    return Scaffold(
      appBar: AppBar(
        title: Text("$topic Insights", style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: results.isEmpty
            ? Center(
          child: Text(
            "No insights available",
            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
          ),
        )
            : ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final religion = results[index];
            final perspectives = (religion['perspectives'] ?? []) as List<dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      religion['religion'] ?? '',
                      style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      religion['overallSummary'] ?? '',
                      style: GoogleFonts.lato(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    if (perspectives.isNotEmpty) ...[
                      Text("Perspectives:",
                          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...perspectives.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${p['perspectiveName']} (${p['adherencePercentage']}%)",
                                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(p['summary'] ?? '', style: GoogleFonts.lato()),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    if ((religion['sharedConcepts'] ?? []).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text("Shared Concepts:",
                          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (religion['sharedConcepts'] as List<dynamic>)
                            .map((concept) => Chip(label: Text(concept)))
                            .toList(),
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
