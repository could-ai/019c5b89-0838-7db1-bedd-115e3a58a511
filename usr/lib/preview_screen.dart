import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ChangeNotifierProvider(create: (_) => ResumeProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resume Preview'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/builder'),
              child: const Text('Edit'),
            ),
          ],
        ),
        body: Column(
          children: [
            const TemplateTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Consumer2<ResumeProvider, TemplateProvider>(
                  builder: (context, resumeProvider, templateProvider, child) {
                    final resume = resumeProvider.resume;
                    final template = templateProvider.selectedTemplate;
                    return ResumeTemplateWidget(resume: resume, template: template);
                  },
                ),
              ),
            ),
            Consumer<ResumeProvider>(
              builder: (context, resumeProvider, child) {
                final resume = resumeProvider.resume;
                final score = resume.calculateScore();
                final improvements = resume.getTopImprovements();
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATS Score: $score/100', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Top 3 Improvements:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ...improvements.map((imp) => Text('• $imp')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ResumeTemplateWidget extends StatelessWidget {
  final ResumeData resume;
  final ResumeTemplate template;

  const ResumeTemplateWidget({super.key, required this.resume, required this.template});

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case ResumeTemplate.classic:
        return _buildClassicResume();
      case ResumeTemplate.modern:
        return _buildModernResume();
      case ResumeTemplate.minimal:
        return _buildMinimalResume();
    }
  }

  Widget _buildClassicResume() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(resume.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Text(resume.summary, style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 16),
          const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          Wrap(children: resume.skills.map((skill) => Text('$skill, ', style: const TextStyle(color: Colors.black))).toList()),
          const SizedBox(height: 16),
          const Text('Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ...resume.experiences.map((exp) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${exp.title} at ${exp.company} (${exp.duration})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ...exp.bullets.map((bullet) => Text('• $bullet', style: const TextStyle(color: Colors.black))),
            ],
          )),
          const SizedBox(height: 16),
          const Text('Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ...resume.projects.map((project) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              Text(project.description, style: const TextStyle(color: Colors.black)),
              ...project.bullets.map((bullet) => Text('• $bullet', style: const TextStyle(color: Colors.black))),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildModernResume() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Text(resume.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          const SizedBox(height: 16),
          Text(resume.summary, style: const TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    Wrap(children: resume.skills.map((skill) => Chip(label: Text(skill))).toList()),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ...resume.experiences.map((exp) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${exp.title} at ${exp.company}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          Text(exp.duration, style: const TextStyle(color: Colors.grey)),
                          ...exp.bullets.map((bullet) => Text('• $bullet', style: const TextStyle(color: Colors.black))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ...resume.projects.map((project) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                Text(project.description, style: const TextStyle(color: Colors.black)),
                ...project.bullets.map((bullet) => Text('• $bullet', style: const TextStyle(color: Colors.black))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMinimalResume() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text(resume.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black))),
          const SizedBox(height: 16),
          Center(child: Text(resume.summary, style: const TextStyle(fontSize: 14, color: Colors.black), textAlign: TextAlign.center)),
          const SizedBox(height: 32),
          const Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Wrap(children: resume.skills.map((skill) => Text('$skill  ', style: const TextStyle(fontSize: 16, color: Colors.black))).toList()),
          const SizedBox(height: 32),
          const Text('Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          ...resume.experiences.map((exp) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${exp.title} • ${exp.company} • ${exp.duration}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                ...exp.bullets.map((bullet) => Text('• $bullet', style: const TextStyle(fontSize: 14, color: Colors.black))),
              ],
            ),
          )),
          const SizedBox(height: 32),
          const Text('Projects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          ...resume.projects.map((project) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                Text(project.description, style: const TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(height: 8),
                ...project.bullets.map((bullet) => Text('• $bullet', style: const TextStyle(fontSize: 14, color: Colors.black))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}