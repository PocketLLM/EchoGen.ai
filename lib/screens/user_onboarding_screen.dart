import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constants/app_theme.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController _pageController = PageController();
  final Map<String, dynamic> _answers = {};
  bool _isSubmitting = false;

  final List<_OnboardingQuestion> _questions = const [
    _OnboardingQuestion(
      id: 'content_focus',
      title: 'What type of podcasts do you want to create?',
      description: 'Tell us the format that inspires you most so we can tailor your prompts.',
      options: ['Storytelling', 'Interviews', 'News recap', 'Educational deep-dives'],
      icon: Icons.podcasts_outlined,
    ),
    _OnboardingQuestion(
      id: 'voice_style',
      title: 'Pick a voice tone you love',
      description: 'We\'ll use this as a default for scripts and voice suggestions.',
      options: ['Friendly', 'Authoritative', 'Playful', 'Relaxed', 'Energetic'],
      icon: Icons.record_voice_over_outlined,
    ),
    _OnboardingQuestion(
      id: 'publishing_cadence',
      title: 'How often do you plan to publish?',
      description: 'Scheduling helps us recommend workflows that match your rhythm.',
      options: ['Daily', 'Weekly', 'Bi-weekly', 'Monthly'],
      icon: Icons.calendar_month_outlined,
    ),
  ];

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_answers[_questions[_currentPage].id] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option to continue'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    final authProvider = context.read<AuthProvider>();
    setState(() => _isSubmitting = true);

    final responses = _questions
        .map(
          (question) => OnboardingAnswerModel(
            questionId: question.id,
            question: question.title,
            answer: _answers[question.id],
          ),
        )
        .toList();

    try {
      await authProvider.submitOnboarding(responses);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on ApiException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _skipOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.skipOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Let\'s personalize EchoGen',
                    style: AppTheme.headingLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll use your preferences to craft better prompts, scripts and voice suggestions.',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    final selected = _answers[question.id];
                    return _OnboardingStep(
                      question: question,
                      selectedValue: selected,
                      onSelected: (value) {
                        setState(() {
                          _answers[question.id] = value;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _questions.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppTheme.primaryBlue,
                      dotColor: AppTheme.border,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_currentPage == _questions.length - 1 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isSubmitting ? null : _skipOnboarding,
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingQuestion {
  const _OnboardingQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final List<String> options;
  final IconData icon;
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.question,
    required this.selectedValue,
    required this.onSelected,
  });

  final _OnboardingQuestion question;
  final dynamic selectedValue;
  final ValueChanged<dynamic> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(question.icon, color: AppTheme.primaryBlue, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          question.title,
          style: AppTheme.headingLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          question.description,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: question.options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.15)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  ),
                  child: Text(option),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
