import 'package:flutter/material.dart';

class MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isBusy;

  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: disabled ? 0.55 : 1,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey[850]!.withOpacity(0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
