import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/builder': (context) => const BuilderScreen(),
        '/preview': (context) => const PreviewScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Resume Builder')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/builder'),
          child: const Text('Start Building Resume'),
        ),
      ),
    );
  }
}

enum ResumeTemplate { classic, modern, minimal }

class ResumeData {
  String name = '';
  String summary = '';
  List<String> skills = [];
  List<Experience> experiences = [];
  List<Project> projects = [];

  int calculateScore() {
    int score = 0;
    if (name.isNotEmpty) score += 10;
    if (summary.length > 40) score += 20;
    if (skills.length >= 8) score += 20;
    if (experiences.isNotEmpty) score += 25;
    if (projects.length >= 2) score += 25;
    return score.clamp(0, 100);
  }

  List<String> getTopImprovements() {
    List<String> improvements = [];
    if (projects.length < 2) improvements.add('Add more projects to showcase your work');
    if (!summary.contains(RegExp(r'\d'))) improvements.add('Include measurable achievements in your summary');
    if (summary.length < 40) improvements.add('Expand your summary to tell more about yourself');
    if (skills.length < 8) improvements.add('Add more skills to highlight your expertise');
    if (experiences.isEmpty) improvements.add('Add experience or internship details');
    return improvements.take(3).toList();
  }
}

class Experience {
  String title = '';
  String company = '';
  String duration = '';
  List<String> bullets = [];
}

class Project {
  String name = '';
  String description = '';
  List<String> bullets = [];
}

class TemplateProvider extends ChangeNotifier {
  ResumeTemplate _selectedTemplate = ResumeTemplate.classic;

  ResumeTemplate get selectedTemplate => _selectedTemplate;

  void setTemplate(ResumeTemplate template) async {
    _selectedTemplate = template;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('template', template.name);
    notifyListeners();
  }

  Future<void> loadTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final templateName = prefs.getString('template');
    if (templateName != null) {
      _selectedTemplate = ResumeTemplate.values.firstWhere(
        (e) => e.name == templateName,
        orElse: () => ResumeTemplate.classic,
      );
    }
    notifyListeners();
  }
}

class ResumeProvider extends ChangeNotifier {
  final ResumeData _resume = ResumeData();

  ResumeData get resume => _resume;

  void updateName(String name) {
    _resume.name = name;
    notifyListeners();
  }

  void updateSummary(String summary) {
    _resume.summary = summary;
    notifyListeners();
  }

  void updateSkills(List<String> skills) {
    _resume.skills = skills;
    notifyListeners();
  }

  void updateExperiences(List<Experience> experiences) {
    _resume.experiences = experiences;
    notifyListeners();
  }

  void updateProjects(List<Project> projects) {
    _resume.projects = projects;
    notifyListeners();
  }
}