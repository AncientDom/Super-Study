import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------- CONFIGURATION ----------------
// GET FREE KEY HERE: https://aistudio.google.com/
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
  
  // App Pages
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
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.flag), label: 'Goal'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Gather Material'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'Quiz & PDF'),
        ],
      ),
    );
  }
}

// ---------------- FEATURE 1: GOAL SELECTION ----------------
class GoalSelectionPage extends StatelessWidget {
  const GoalSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.track_changes, size: 80, color: Colors.teal),
          const SizedBox(height: 20),
          const Text("Current Goal: UPSC Preparation", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () { /* Add Logic to change goal */ },
            child: const Text("Set New Goal"),
          )
        ],
      ),
    );
  }
}

// ---------------- FEATURE 2: MATERIAL GATHERER (The Engine) ----------------
class GathererPage extends StatefulWidget {
  const GathererPage({super.key});

  @override
  State<GathererPage> createState() => _GathererPageState();
}

class _GathererPageState extends State<GathererPage> {
  final TextEditingController _searchController = TextEditingController();
  String _resultText = "Search for a topic to gather notes...";
  bool _isLoading = false;

  // AI & Search Logic
  Future<void> _gatherMaterial() async {
    setState(() { _isLoading = true; _resultText = "Scouring the internet & Generating Notes..."; });

    try {
      final topic = _searchController.text;

      // 1. FREE VIDEO SEARCH (Youtube Explode)
      final yt = YoutubeExplode();
      var videoResult = await yt.search.search(topic);
      var videoTitle = videoResult.first.title;
      var videoAuthor = videoResult.first.author;
      yt.close();

      // 2. FREE BOOK SEARCH (Open Library)
      final bookUrl = Uri.parse('https://openlibrary.org/search.json?q=$topic&limit=1');
      final bookResponse = await http.get(bookUrl);
      final bookData = json.decode(bookResponse.body);
      String bookTitle = "No book found";
      if (bookData['docs'].isNotEmpty) {
        bookTitle = bookData['docs'][0]['title'];
      }

      // 3. AI SUMMARY (Gemini Free Tier)
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final prompt = 'Create a structured study note for "$topic". Include insights from a video titled "$videoTitle" and a book titled "$bookTitle". Make it detailed with headings.';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _resultText = response.text ?? "Failed to generate summary.";
      });

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
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Enter Topic (e.g. Thermodynamics)",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _gatherMaterial,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Gather & Create Notes"),
            ),
            const Divider(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : SingleChildScrollView(child: Text(_resultText)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- FEATURE 3: QUIZ & EXPORT ----------------
class QuizGeneratorPage extends StatelessWidget {
  const QuizGeneratorPage({super.key});

  Future<void> _generateAndDownloadPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text("Generated Study Quiz", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text("Q1: What is the first law of thermodynamics?"),
              pw.SizedBox(height: 50),
              pw.Text("Space for answers..."),
            ]
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text("Convert Notes to Quiz", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _generateAndDownloadPdf,
            icon: const Icon(Icons.download),
            label: const Text("Generate PDF Quiz"),
          )
        ],
      ),
    );
  }
}
