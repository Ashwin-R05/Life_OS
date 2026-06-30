import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/journal_controller.dart';
import '../../onboarding/widgets/glass_card.dart';
import '../../onboarding/widgets/primary_button.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = 'Okay';

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Great', 'icon': '🤩', 'color': Colors.greenAccent},
    {'label': 'Good', 'icon': '😊', 'color': Colors.lightGreenAccent},
    {'label': 'Okay', 'icon': '😐', 'color': Colors.amberAccent},
    {'label': 'Bad', 'icon': '😔', 'color': Colors.orangeAccent},
    {'label': 'Terrible', 'icon': '😫', 'color': Colors.redAccent},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitEntry() {
    if (_contentController.text.trim().isEmpty) return;

    Provider.of<JournalController>(context, listen: false).addEntry(
      _contentController.text.trim(),
      _selectedMood,
    );

    _contentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Provider.of<JournalController>(context);

    return Scaffold(
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Journal',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your mood and thoughts.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Entry Input Area
                    GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How are you feeling?',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _moods.map((mood) {
                                final isSelected = _selectedMood == mood['label'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedMood = mood['label'];
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? (mood['color'] as Color).withValues(alpha: 0.2) : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? (mood['color'] as Color) : (isDark ? Colors.white24 : Colors.black12),
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(mood['icon'] as String, style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Text(
                                          mood['label'] as String,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: isSelected ? (mood['color'] as Color) : null,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _contentController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Write your thoughts here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: PrimaryButton(
                              text: 'Save Entry',
                              onPressed: _submitEntry,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Past Entries',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Entries List
                    Expanded(
                      child: controller.entries.isEmpty
                          ? Center(
                              child: Text(
                                'No entries yet. Start writing!',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.entries.length,
                              itemBuilder: (context, index) {
                                final entry = controller.entries[index];
                                final moodData = _moods.firstWhere((m) => m['label'] == entry.mood, orElse: () => _moods[2]);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GlassCard(
                                    borderRadius: 12,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(moodData['icon'] as String, style: const TextStyle(fontSize: 18)),
                                                const SizedBox(width: 8),
                                                Text(
                                                  entry.mood,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: moodData['color'] as Color,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')} ${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: isDark ? Colors.white54 : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          entry.content,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
