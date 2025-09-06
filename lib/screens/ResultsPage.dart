import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

import 'insights_page.dart'; // Your existing InsightsPage

class ResultsPage extends StatefulWidget {
  final String religionName;
  final String searchQuery;
  final List<String> results;
  final String insightsApiUrl;

  const ResultsPage({
    super.key,
    required this.religionName,
    required this.searchQuery,
    required this.results,
    required this.insightsApiUrl,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  int? currentlyReadingIndex;
  bool isSpeaking = false;
  String selectedLanguage = "en";
  List<String> chunks = [];
  int currentChunkIndex = 0;

  Map<String, List<String>> translatedResults = {};
  Map<String, dynamic>? insightsData;
  bool isLoadingInsights = false;

  @override
  void initState() {
    super.initState();
    translatedResults["en"] = widget.results;
    _setupTTS();
    _fetchInsights();
  }

  void _setupTTS() {
    _flutterTts.setCompletionHandler(() {
      if (currentChunkIndex + 1 < chunks.length && isSpeaking) {
        currentChunkIndex++;
        _flutterTts.speak(chunks[currentChunkIndex]);
      } else {
        setState(() {
          isSpeaking = false;
          currentlyReadingIndex = null;
          currentChunkIndex = 0;
          chunks = [];
        });
      }
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        isSpeaking = false;
        currentlyReadingIndex = null;
        currentChunkIndex = 0;
        chunks = [];
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
        currentlyReadingIndex = null;
        currentChunkIndex = 0;
        chunks = [];
      });
    });
  }

  Future<void> _fetchInsights() async {
    setState(() => isLoadingInsights = true);

    try {
      final response = await http.post(
        Uri.parse(widget.insightsApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": widget.searchQuery}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) setState(() => insightsData = data);
      } else {
        throw Exception("Failed to fetch insights: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error fetching insights: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoadingInsights = false);
    }
  }

  Future<void> _translateIfNeeded(String lang) async {
    if (!translatedResults.containsKey(lang)) {
      List<String> translatedList = [];
      for (var text in widget.results) {
        if (lang == "en") {
          translatedList.add(text);
        } else {
          final translation = await _translator.translate(text, to: lang);
          translatedList.add(translation.text);
        }
      }
      translatedResults[lang] = translatedList;
    }
  }

  Future<void> _toggleSpeak(String text, int index) async {
    if (isSpeaking && currentlyReadingIndex == index) {
      _flutterTts.stop();
      return;
    }

    _flutterTts.stop();

    final ttsText = translatedResults[selectedLanguage]![index];
    chunks = ttsText.split(RegExp(r'(?<=[.?!])\s+'));
    currentChunkIndex = 0;

    String ttsLang = "en-US";
    switch (selectedLanguage) {
      case "hi":
        ttsLang = "hi-IN";
        break;
      case "te":
        ttsLang = "te-IN";
        break;
      case "ml":
        ttsLang = "ml-IN";
        break;
    }

    await _flutterTts.setLanguage(ttsLang);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    setState(() {
      isSpeaking = true;
      currentlyReadingIndex = index;
      currentChunkIndex = 0;
    });

    _flutterTts.speak(chunks[currentChunkIndex]);
  }

  List<Widget> _buildHighlightedParagraphs(String text, Color normalColor) {
    final paragraphs = text.split(RegExp(r'(?=\d+\.\s)'));
    List<Widget> widgets = [];

    for (final paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) continue;

      final textChunks = paragraph.split(RegExp(r'(?<=[.?!])\s+'));
      List<InlineSpan> spans = [];

      for (String chunk in textChunks) {
        final regex = RegExp(r'"(.*?)"');
        int lastMatchEnd = 0;
        List<InlineSpan> chunkSpans = [];

        for (final match in regex.allMatches(chunk)) {
          if (match.start > lastMatchEnd) {
            chunkSpans.add(TextSpan(
              text: chunk.substring(lastMatchEnd, match.start),
              style: GoogleFonts.lato(fontSize: 16, height: 1.6, color: normalColor),
            ));
          }

          chunkSpans.add(TextSpan(
            text: match.group(0), // Correct usage
            style: GoogleFonts.lato(
                fontSize: 16, height: 1.6, color: Colors.deepOrange, fontWeight: FontWeight.bold),
          ));

          lastMatchEnd = match.end;
        }

        if (lastMatchEnd < chunk.length) {
          chunkSpans.add(TextSpan(
            text: chunk.substring(lastMatchEnd),
            style: GoogleFonts.lato(fontSize: 16, height: 1.6, color: normalColor),
          ));
        }

        spans.add(TextSpan(children: chunkSpans));
        spans.add(const TextSpan(text: " "));
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: RichText(text: TextSpan(children: spans)),
      ));
    }

    return widgets;
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Only stop TTS
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final normalTextColor = Theme.of(context).textTheme.bodyLarge?.color ??
        (isDarkMode ? Colors.white70 : Colors.black87);

    final displayResults = translatedResults[selectedLanguage] ?? widget.results;
    final hasRelevantData = !(displayResults.length == 1 &&
        displayResults.first == "Question Asked is Not Relevant!");

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.religionName} Insights",
            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.white),
            items: const [
              DropdownMenuItem(value: "en", child: Text("English")),
              DropdownMenuItem(value: "hi", child: Text("Hindi")),
              DropdownMenuItem(value: "te", child: Text("Telugu")),
              DropdownMenuItem(value: "ml", child: Text("Malayalam")),
            ],
            onChanged: (value) async {
              if (value != null) {
                await _translateIfNeeded(value);
                setState(() => selectedLanguage = value);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: displayResults.isEmpty
                  ? Center(
                  child: Text("No data found", style: TextStyle(color: normalTextColor)))
                  : !hasRelevantData
                  ? Center(
                  child: Text("Question Asked is Not Relevant!",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.brown)))
                  : ListView.builder(
                itemCount: displayResults.length,
                itemBuilder: (context, index) {
                  final text = displayResults[index];
                  return Card(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildHighlightedParagraphs(text, normalTextColor),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _toggleSpeak(text, index),
                              icon: Icon(currentlyReadingIndex == index && isSpeaking
                                  ? Icons.stop
                                  : Icons.volume_up),
                              label: Text(currentlyReadingIndex == index && isSpeaking
                                  ? "Stop"
                                  : "Read"),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (hasRelevantData)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: isLoadingInsights
                    ? null
                    : () {
                  // Stop TTS immediately
                  _flutterTts.stop();
                  setState(() {
                    isSpeaking = false;
                    currentlyReadingIndex = null;
                    currentChunkIndex = 0;
                    chunks = [];
                  });

                  if (insightsData != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InsightsPage(data: insightsData!)),
                    );
                  }
                },
                child: isLoadingInsights
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("View Comparative Insights"),
              ),
            ),
        ],
      ),
    );
  }
}
