import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SlideToOpen extends StatefulWidget {
  final VoidCallback onSlide;
  final bool isOpening;
  final bool isSuccess;

  const SlideToOpen({
    super.key,
    required this.onSlide,
    required this.isOpening,
    required this.isSuccess,
  });

  @override
  State<SlideToOpen> createState() => _SlideToOpenState();
}

class _SlideToOpenState extends State<SlideToOpen> with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _triggered = false;

  static const double _height = 48;
  static const double _thumbSize = 40;
  static const double _padding = 4;

  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _resetAnimation = Tween<double>(begin: 0, end: 0).animate(_resetController);
    _resetController.addListener(() {
      setState(() => _dragPosition = _resetAnimation.value);
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlideToOpen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpening && !widget.isSuccess && (oldWidget.isSuccess || oldWidget.isOpening)) {
      _triggered = false;
      _animateReset();
    }
  }

  void _animateReset() {
    _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
    );
    _resetController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxDrag = constraints.maxWidth - _thumbSize - _padding * 2;
          final displayPos = widget.isSuccess ? maxDrag : _dragPosition.clamp(0.0, maxDrag);
          final progress = maxDrag > 0 ? (displayPos / maxDrag).clamp(0.0, 1.0) : 0.0;
          final locked = widget.isOpening || widget.isSuccess;

          return GestureDetector(
            onHorizontalDragStart: locked ? null : (_) => _resetController.stop(),
            onHorizontalDragUpdate: locked
                ? null
                : (details) {
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
                    });
                    if (!_triggered && _dragPosition >= maxDrag * 0.9) {
                      _triggered = true;
                      widget.onSlide();
                    }
                  },
            onHorizontalDragEnd: locked
                ? null
                : (_) {
                    if (!_triggered) _animateReset();
                  },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Stack(
                children: [
                  // Progress fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: _padding + _thumbSize + (maxDrag * progress),
                    decoration: BoxDecoration(
                      color: widget.isSuccess
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  // Label
                  Center(
                    child: Opacity(
                      opacity: (1 - progress * 1.8).clamp(0.0, 1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: _thumbSize + 8),
                          const Text(
                            'Slide to open',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),
                  // Thumb
                  Positioned(
                    left: _padding + (maxDrag * progress),
                    top: _padding,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: widget.isSuccess ? AppColors.success : AppColors.primary,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isSuccess ? AppColors.success : AppColors.primary).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isSuccess
                            ? Icons.check_rounded
                            : widget.isOpening
                                ? Icons.sync_rounded
                                : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
