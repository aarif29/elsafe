import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class DashboardInfoSection extends StatefulWidget {
  const DashboardInfoSection({super.key});

  static const _tips = [
    (
      title: 'Tidak ada yang lebih penting dari jiwa manusia',
      description:
          'Keselamatan diri dan orang sekitar selalu menjadi prioritas.',
    ),
    (
      title: 'Waspadai jaringan terdampak',
      description:
          'Kabel putus, tiang roboh, atau pohon menimpa jaringan harus segera dilaporkan.',
    ),
    (
      title: 'Dokumentasikan dari posisi aman',
      description: 'Catat lokasi dan kondisi tanpa mendekati titik bahaya.',
    ),
    (
      title: 'Pastikan tindak lanjut tercatat',
      description: 'Lengkapi kategori KMU/ROW, bukti, dan status temuan.',
    ),
    (
      title: 'Zero Harm, Zero Loss. Safety First.',
      description:
          'Cegah risiko, catat potensi bahaya, pantau tindak lanjutnya.',
    ),
  ];

  @override
  State<DashboardInfoSection> createState() => _DashboardInfoSectionState();
}

class _DashboardInfoSectionState extends State<DashboardInfoSection>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _rotationDuration = Duration(seconds: 5);

  late final AnimationController _rotationController;
  int _currentIndex = 0;
  bool _isHovered = false;
  bool _isPaused = false;
  bool _isAppActive = true;
  bool _disableAnimations = false;

  bool get _shouldRotate =>
      !_isHovered && !_isPaused && _isAppActive && !_disableAnimations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _rotationController = AnimationController(
      vsync: this,
      duration: _rotationDuration,
    )..addStatusListener(_handleRotationStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _syncRotation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
    _syncRotation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rotationController
      ..removeStatusListener(_handleRotationStatus)
      ..dispose();
    super.dispose();
  }

  void _handleRotationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_shouldRotate || !mounted) {
      return;
    }

    setState(() {
      _currentIndex = (_currentIndex + 1) % DashboardInfoSection._tips.length;
    });
    _rotationController.forward(from: 0);
  }

  void _syncRotation() {
    if (!_shouldRotate) {
      _rotationController.stop();
    } else if (!_rotationController.isAnimating) {
      _rotationController.forward();
    }
  }

  void _showTip(int index) {
    setState(() {
      _currentIndex =
          (index + DashboardInfoSection._tips.length) %
          DashboardInfoSection._tips.length;
    });
    _rotationController.value = 0;
    _syncRotation();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    _syncRotation();
  }

  @override
  Widget build(BuildContext context) {
    final tip = DashboardInfoSection._tips[_currentIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, color: context.borderColor),
        const SizedBox(height: 14),
        MouseRegion(
          onEnter: (_) {
            _isHovered = true;
            _syncRotation();
          },
          onExit: (_) {
            _isHovered = false;
            _syncRotation();
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: context.isDark ? 0.16 : 0.07,
              ),
              border: Border.all(color: context.borderColor),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Tips K3',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentIndex + 1}/${DashboardInfoSection._tips.length}',
                      semanticsLabel:
                          'Tip ${_currentIndex + 1} dari ${DashboardInfoSection._tips.length}',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 4),
                    _controlButton(
                      icon: Icons.chevron_left,
                      tooltip: 'Tip sebelumnya',
                      onPressed: () => _showTip(_currentIndex - 1),
                    ),
                    _controlButton(
                      icon:
                          _isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                      tooltip:
                          _isPaused
                              ? 'Lanjutkan rotasi tip'
                              : 'Jeda rotasi tip',
                      onPressed: _togglePause,
                    ),
                    _controlButton(
                      icon: Icons.chevron_right,
                      tooltip: 'Tip berikutnya',
                      onPressed: () => _showTip(_currentIndex + 1),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                AnimatedSwitcher(
                  duration:
                      _disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child: SizedBox(
                    key: ValueKey(_currentIndex),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 15,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tip.description,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!_disableAnimations)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder:
                          (context, child) => LinearProgressIndicator(
                            value: _rotationController.value,
                            minHeight: 2,
                            backgroundColor: context.borderColor,
                            valueColor: AlwaysStoppedAnimation(
                              colorScheme.primary,
                            ),
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        icon: Icon(icon, size: 20),
        color: context.textSecondary,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
