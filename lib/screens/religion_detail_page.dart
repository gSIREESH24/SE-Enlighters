import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ReligionDetailPage extends StatelessWidget {
  final String religionName;
  final String searchQuery;

  const ReligionDetailPage({
    super.key,
    required this.religionName,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    // Dummy detailed content - replace with actual data retrieval based on religionName and searchQuery
    final String detailedContent =
        "Exploring deeper into $religionName in the context of '$searchQuery'. "
        "Here you would find extensive information, historical background, core tenets, "
        "philosophical interpretations, and practical applications related to your search. "
        "This section can be populated dynamically from an API or a local database "
        "to provide a rich and informative experience specific to the selected religion. "
        "For example, if '$searchQuery' was 'peace', this page would discuss how "
        "$religionName approaches concepts of inner peace, conflict resolution, "
        "and community harmony through its scriptures and practices. "
        "Further sections could include: "
        "Key figures and their contributions. "
        "Major festivals and rituals. "
        "Ethical teachings and moral frameworks. "
        "Sacred texts and their interpretations. "
        "Modern relevance and global impact. "
        "This detailed view aims to provide a comprehensive understanding tailored to the user's inquiry.";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$religionName & '$searchQuery'",
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Deep Dive: $religionName",
              style: GoogleFonts.merriweather(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              detailedContent.replaceAll("\n", " "),
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: onSurfaceColor.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
