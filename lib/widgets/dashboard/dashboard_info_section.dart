import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class DashboardInfoSection extends StatefulWidget {
  const DashboardInfoSection({super.key});

  @override
  State<DashboardInfoSection> createState() => _DashboardInfoSectionState();
}

class _DashboardInfoSectionState extends State<DashboardInfoSection>
    with SingleTickerProviderStateMixin {
  static const _tips = [
    'Tidak ada yang lebih penting dari jiwa manusia.',
    'Bekerja itu jalan rezeki, berdoa itu sumber rezeki.',
    'Zero Harm, Zero Loss. Safety First.',
    'Zero accident, no tolerance!',
  ];

  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % _tips.length;
        });
        _fadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips K3',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline,
                    color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _tips[_currentIndex],
                        style: TextStyle(
                          color: context.isDark
                              ? Colors.amber[300]
                              : Colors.orange[800],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        _tips.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 4),
                          width: i == _currentIndex ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _currentIndex
                                ? Colors.amber
                                : context.textDisabled,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}