import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateProvider>().loadTemplate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ChangeNotifierProvider(create: (_) => ResumeProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resume Builder'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/preview'),
              child: const Text('Preview'),
            ),
          ],
        ),
        body: Column(
          children: [
            const TemplateTabs(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (value) => context.read<ResumeProvider>().updateName(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Summary'),
                      maxLines: 3,
                      onChanged: (value) => context.read<ResumeProvider>().updateSummary(value),
                    ),
                    const SizedBox(height: 16),
                    const SkillsSection(),
                    const SizedBox(height: 16),
                    const ExperiencesSection(),
                    const SizedBox(height: 16),
                    const ProjectsSection(),
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

class TemplateTabs extends StatelessWidget {
  const TemplateTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final templateProvider = context.watch<TemplateProvider>();
    return Container(
      color: Colors.grey[100],
      child: Row(
        children: ResumeTemplate.values.map((template) {
          final isSelected = templateProvider.selectedTemplate == template;
          return Expanded(
            child: InkWell(
              onTap: () => templateProvider.setTemplate(template),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  template.name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: resumeProvider.resume.skills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                final skills = List<String>.from(resumeProvider.resume.skills);
                skills.remove(skill);
                resumeProvider.updateSkills(skills);
              },
            );
          }).toList(),
        ),
        TextField(
          decoration: const InputDecoration(hintText: 'Add skill'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              final skills = List<String>.from(resumeProvider.resume.skills);
              skills.add(value);
              resumeProvider.updateSkills(skills);
            }
          },
        ),
      ],
    );
  }
}

class ExperiencesSection extends StatelessWidget {
  const ExperiencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...resumeProvider.resume.experiences.map((exp) => ExperienceWidget(exp)),
        TextButton(
          onPressed: () {
            final experiences = List<Experience>.from(resumeProvider.resume.experiences);
            experiences.add(Experience());
            resumeProvider.updateExperiences(experiences);
          },
          child: const Text('Add Experience'),
        ),
      ],
    );
  }
}

class ExperienceWidget extends StatefulWidget {
  final Experience exp;
  const ExperienceWidget(this.exp, {super.key});

  @override
  State<ExperienceWidget> createState() => _ExperienceWidgetState();
}

class _ExperienceWidgetState extends State<ExperienceWidget> {
  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.exp.title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (value) {
                      widget.exp.title = value;
                      resumeProvider.updateExperiences(List.from(resumeProvider.resume.experiences));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.exp.company,
                    decoration: const InputDecoration(labelText: 'Company'),
                    onChanged: (value) {
                      widget.exp.company = value;
                      resumeProvider.updateExperiences(List.from(resumeProvider.resume.experiences));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.exp.duration,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    onChanged: (value) {
                      widget.exp.duration = value;
                      resumeProvider.updateExperiences(List.from(resumeProvider.resume.experiences));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.exp.bullets.map((bullet) => BulletWidget(bullet, widget.exp.bullets)),
            TextButton(
              onPressed: () {
                widget.exp.bullets.add('');
                resumeProvider.updateExperiences(List.from(resumeProvider.resume.experiences));
              },
              child: const Text('Add Bullet'),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletWidget extends StatefulWidget {
  final String bullet;
  final List<String> bullets;
  const BulletWidget(this.bullet, this.bullets, {super.key});

  @override
  State<BulletWidget> createState() => _BulletWidgetState();
}

class _BulletWidgetState extends State<BulletWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bullet);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _startsWithActionVerb(String text) {
    final actionVerbs = ['Built', 'Developed', 'Designed', 'Implemented', 'Led', 'Improved', 'Created', 'Optimized', 'Automated'];
    return actionVerbs.any((verb) => text.trim().startsWith(verb));
  }

  bool _hasNumericIndicator(String text) {
    return RegExp(r'\d').hasMatch(text) || text.contains('%') || text.contains('k') || text.contains('x');
  }

  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    return Column(
      children: [
        Row(
          children: [
            const Text('• '),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  final index = widget.bullets.indexOf(widget.bullet);
                  if (index != -1) {
                    widget.bullets[index] = value;
                    resumeProvider.updateExperiences(List.from(resumeProvider.resume.experiences));
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                widget.bullets.remove(widget.bullet);
                resumeProvider.updateExperiences(List.from(resumeProvider.resume.experiences));
              },
            ),
          ],
        ),
        if (!_startsWithActionVerb(_controller.text))
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Start with a strong action verb.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        if (!_hasNumericIndicator(_controller.text))
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Add measurable impact (numbers).',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...resumeProvider.resume.projects.map((project) => ProjectWidget(project)),
        TextButton(
          onPressed: () {
            final projects = List<Project>.from(resumeProvider.resume.projects);
            projects.add(Project());
            resumeProvider.updateProjects(projects);
          },
          child: const Text('Add Project'),
        ),
      ],
    );
  }
}

class ProjectWidget extends StatefulWidget {
  final Project project;
  const ProjectWidget(this.project, {super.key});

  @override
  State<ProjectWidget> createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.project.name,
              decoration: const InputDecoration(labelText: 'Project Name'),
              onChanged: (value) {
                widget.project.name = value;
                resumeProvider.updateProjects(List.from(resumeProvider.resume.projects));
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.project.description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              onChanged: (value) {
                widget.project.description = value;
                resumeProvider.updateProjects(List.from(resumeProvider.resume.projects));
              },
            ),
            const SizedBox(height: 16),
            ...widget.project.bullets.map((bullet) => BulletWidget(bullet, widget.project.bullets)),
            TextButton(
              onPressed: () {
                widget.project.bullets.add('');
                resumeProvider.updateProjects(List.from(resumeProvider.resume.projects));
              },
              child: const Text('Add Bullet'),
            ),
          ],
        ),
      ),
    );
  }
}