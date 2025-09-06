import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import 'ResultsPage.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuestion;
  final Function(String)? onQuerySubmitted;

  const SearchPage({super.key, this.initialQuestion, this.onQuerySubmitted});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;
  final StorageService _storageService = StorageService();

  final Map<String, double> _religionData = {
    "Hindu": 33.4,
    "Christian": 33.3,
    "Islam": 33.3,
  };

  Map<String, List<String>> _structuredResults = {};
  int? _selectedReligionIndex;
  bool _isLoading = false;

  final String hinduUrl = "https://se-app-project-backend.onrender.com/ask/gita";
  final String christianUrl = "https://se-app-project-backend.onrender.com/ask/bible";
  final String islamUrl = "https://se-app-project-backend.onrender.com/ask/quran";

  final String insightsUrl = "https://se-app-project-backend.onrender.com/ask/all";

  @override
  void initState() {
    super.initState();
    _storageService.init();
    _controller = TextEditingController(text: widget.initialQuestion ?? "");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchReligionResults(String query, String apiUrl) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"question": query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["summary"] != "[]") return [data["summary"].toString()];
      return ["Not Relevant Question\n\nNo summary found"];
    } else {
      throw Exception("Failed to fetch: ${response.statusCode} ${response.body}");
    }
  }

  Future<Map<String, List<String>>> _fetchResultsFromBackend(String query) async {
    final hinduResults = await _fetchReligionResults(query, hinduUrl);
    final christianResults = await _fetchReligionResults(query, christianUrl);
    final islamResults = await _fetchReligionResults(query, islamUrl);

    return {
      "Hindu": hinduResults,
      "Christian": christianResults,
      "Islam": islamResults,
    };
  }

  void _onSearchAction(String query) async {
    if (query.trim().isEmpty) return;

    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final results = await _fetchResultsFromBackend(query);

      setState(() {
        _structuredResults = results;
        _selectedReligionIndex = null;
        _isLoading = false;
      });

      final recent = _storageService.getRecentSearches();
      recent.remove(query);
      recent.insert(0, query);
      await _storageService.setRecentSearches(recent.take(10).toList());

      if (widget.onQuerySubmitted != null) {
        widget.onQuerySubmitted!(query);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          // Dismiss keyboard on tapping outside
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: onSurfaceColor),
                        decoration: InputDecoration(
                          hintText: "Ask your question...",
                          hintStyle: TextStyle(color: onSurfaceColor.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.brown[50],
                        ),
                        onSubmitted: _onSearchAction,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _onSearchAction(_controller.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: const Text("Ask", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  Center(
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: Lottie.asset(
                        'assets/animations/Wave Loop.json',
                        repeat: true,
                        animate: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Religious Insights:",
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: onSurfaceColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(height: 220, child: _buildPieChart(isDarkMode)),
                  const SizedBox(height: 20),
                  _buildReligionCard(isDarkMode),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isDarkMode) {
    final religionColors = {
      "Hindu": Colors.orange,
      "Christian": Colors.white,
      "Islam": Colors.green
    };

    return PieChart(
      PieChartData(
        sections: List.generate(_religionData.length, (i) {
          final entry = _religionData.entries.elementAt(i);
          return PieChartSectionData(
            value: entry.value,
            color: religionColors[entry.key] ?? Colors.grey,
            radius: _selectedReligionIndex == i ? 100: 80,
            title: entry.key,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blueGrey : Colors.black,
            ),
          );
        }),
        sectionsSpace: 4,
        centerSpaceRadius: 0,
        pieTouchData: PieTouchData(
          touchCallback: (_, response) {
            if (response != null && response.touchedSection != null) {
              final idx = response.touchedSection!.touchedSectionIndex;
              if (idx >= 0) {
                setState(() {
                  _selectedReligionIndex = idx;
                });
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildReligionCard(bool isDarkMode) {
    if (_selectedReligionIndex == null || _structuredResults.isEmpty) {
      return Center(
        child: Text(
          "Select a religion from the chart above",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }

    final String religionName = _religionData.keys.toList()[_selectedReligionIndex!];

    final Map<String, String> religionImages = {
      "Hindu": "assets/images/Background.jpg",
      "Christian": "assets/images/Background.jpg",
      "Islam": "assets/images/Background.jpg",
    };

    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              religionName: religionName,
              searchQuery: _controller.text,
              results: _structuredResults[religionName] ?? [],
              insightsApiUrl: insightsUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                religionImages[religionName] ?? "assets/images/default.jpg",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                color: isDarkMode ? Colors.black.withOpacity(0.4) : null,
                colorBlendMode: isDarkMode ? BlendMode.darken : null,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDarkMode
                    ? Colors.black.withOpacity(0.25)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: Text(
                religionName,
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
