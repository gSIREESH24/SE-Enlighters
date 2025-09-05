import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class ResultsPage extends StatefulWidget {
  final String religionName;
  final String searchQuery;
  final List<String> results;

  const ResultsPage({
    super.key,
    required this.religionName,
    required this.searchQuery,
    required this.results,
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

  @override
  void initState() {
    super.initState();

    _flutterTts.setCompletionHandler(() async {
      if (currentChunkIndex + 1 < chunks.length && isSpeaking) {
        currentChunkIndex++;
        setState(() {});
        await _flutterTts.speak(chunks[currentChunkIndex]);
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

    // Initialize with English
    translatedResults["en"] = widget.results;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
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
      await _flutterTts.stop();
      return;
    }

    await _flutterTts.stop();

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

    await _flutterTts.speak(chunks[currentChunkIndex]);
  }

  List<InlineSpan> _buildHighlightedText(
      String text, Color normalColor, Color highlightColor) {
    final textChunks = text.split(RegExp(r'(?<=[.?!])\s+'));
    List<InlineSpan> spans = [];

    for (int i = 0; i < textChunks.length; i++) {
      spans.add(TextSpan(
        text: textChunks[i] + ' ',
        style: GoogleFonts.lato(
          fontSize: 16,
          height: 1.5,
          color: (isSpeaking &&
              currentlyReadingIndex != null &&
              i == currentChunkIndex)
              ? highlightColor
              : normalColor,
          fontWeight: (isSpeaking &&
              currentlyReadingIndex != null &&
              i == currentChunkIndex)
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final normalTextColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
            (isDarkMode ? Colors.white70 : Colors.black87);
    final highlightTextColor =
    isDarkMode ? Colors.amber[300]! : Colors.brown.shade700;

    final displayResults =
        translatedResults[selectedLanguage] ?? widget.results;

    final hasRelevantData =
    !(displayResults.length == 1 &&
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: displayResults.isEmpty
            ? Center(
            child: Text("No data found",
                style: TextStyle(color: normalTextColor)))
            : !hasRelevantData
            ? Center(
            child: Text("Question Asked is Not Relevant!",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: highlightTextColor)))
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
                    RichText(
                      text: TextSpan(
                        children: _buildHighlightedText(
                            text, normalTextColor, highlightTextColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleSpeak(text, index),
                        icon: Icon(
                            currentlyReadingIndex == index &&
                                isSpeaking
                                ? Icons.stop
                                : Icons.volume_up),
                        label: Text(
                            currentlyReadingIndex == index &&
                                isSpeaking
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
    );
  }
}
