import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:pdf/widgets.dart' as pw;  <-- Removed for now
// import 'package:pdf/pdf.dart';            <-- Removed for now
// import 'package:printing/printing.dart';  <-- Removed for now
import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------- CONFIGURATION ----------------
const String apiKey = 'YOUR_GEMINI_API_KEY'; 

void main() {
  runApp(const StudyApp());
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyGatherer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const GoalSelectionPage(),
    const GathererPage(),
    const QuizGeneratorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() { _selectedIndex = index; });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.flag), label: 'Goal'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Gather Material'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'Quiz (Beta)'),
        ],
      ),
    );
  }
}

class GoalSelectionPage extends StatelessWidget {
  const GoalSelectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Goal Selection Page"));
  }
}

class GathererPage extends StatefulWidget {
  const GathererPage({super.key});
  @override
  State<GathererPage> createState() => _GathererPageState();
}

class _GathererPageState extends State<GathererPage> {
  final TextEditingController _searchController = TextEditingController();
  String _resultText = "Search for a topic...";
  bool _isLoading = false;

  Future<void> _gatherMaterial() async {
    setState(() { _isLoading = true; _resultText = "Searching..."; });
    try {
      final topic = _searchController.text;
      final yt = YoutubeExplode();
      var videoResult = await yt.search.search(topic);
      var videoTitle = videoResult.isNotEmpty ? videoResult.first.title : "No Video";
      yt.close();

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final prompt = 'Summarize "$topic" considering video "$videoTitle".';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() { _resultText = response.text ?? "No text generated."; });
    } catch (e) {
      setState(() { _resultText = "Error: $e"; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Gatherer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _searchController, decoration: const InputDecoration(labelText: "Topic")),
            ElevatedButton(onPressed: _isLoading ? null : _gatherMaterial, child: const Text("Search")),
            Expanded(child: SingleChildScrollView(child: Text(_resultText))),
          ],
        ),
      ),
    );
  }
}

class QuizGeneratorPage extends StatelessWidget {
  const QuizGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("PDF Generation temporarily disabled for build fix."),
    );
  }
}
