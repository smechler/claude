import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/door.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'slide_to_open.dart';

enum _OpenState { idle, opening, success }

class DoorCard extends StatefulWidget {
  final Door door;
  const DoorCard({super.key, required this.door});

  @override
  State<DoorCard> createState() => _DoorCardState();
}

class _DoorCardState extends State<DoorCard> with SingleTickerProviderStateMixin {
  _OpenState _state = _OpenState.idle;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleOpen() async {
    if (_state != _OpenState.idle) return;
    final provider = context.read<AppProvider>();
    if (provider.hapticFeedback) HapticFeedback.mediumImpact();

    setState(() => _state = _OpenState.opening);
    _pulseController.repeat(reverse: true);

    await provider.openDoor(widget.door);

    _pulseController.stop();
    _pulseController.reset();
    if (provider.hapticFeedback) HapticFeedback.heavyImpact();

    setState(() => _state = _OpenState.success);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _state = _OpenState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final useSlide = context.watch<AppProvider>().useSlideToOpen;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _state == _OpenState.opening ? _pulseAnimation.value : 1.0,
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _state == _OpenState.success
                ? AppColors.success.withValues(alpha: 0.5)
                : _state == _OpenState.opening
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border,
            width: _state != _OpenState.idle ? 1.5 : 0.5,
          ),
          boxShadow: _state == _OpenState.success
              ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.12), blurRadius: 20, spreadRadius: 2)]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _typeColor(widget.door.type).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_typeIcon(widget.door.type), color: _typeColor(widget.door.type), size: 22),
                  ),
                  const Spacer(),
                  _statusBadge(widget.door.isOnline),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.door.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.door.location,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              useSlide
                  ? SlideToOpen(
                      onSlide: _handleOpen,
                      isOpening: _state == _OpenState.opening,
                      isSuccess: _state == _OpenState.success,
                    )
                  : _OpenButton(state: _state, onTap: _handleOpen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool online) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (online ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: online ? AppColors.success : AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            online ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: online ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(DoorType t) {
    switch (t) {
      case DoorType.gate:
        return Icons.fence_rounded;
      case DoorType.door:
        return Icons.door_front_door_rounded;
      case DoorType.elevator:
        return Icons.elevator_rounded;
      case DoorType.garage:
        return Icons.garage_rounded;
    }
  }

  Color _typeColor(DoorType t) {
    switch (t) {
      case DoorType.gate:
        return AppColors.primary;
      case DoorType.door:
        return AppColors.secondary;
      case DoorType.elevator:
        return AppColors.warning;
      case DoorType.garage:
        return AppColors.purple;
    }
  }
}

class _OpenButton extends StatelessWidget {
  final _OpenState state;
  final VoidCallback onTap;

  const _OpenButton({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final IconData icon;

    switch (state) {
      case _OpenState.idle:
        color = AppColors.primary;
        label = 'Open';
        icon = Icons.lock_open_rounded;
      case _OpenState.opening:
        color = AppColors.primary;
        label = 'Opening...';
        icon = Icons.sync_rounded;
      case _OpenState.success:
        color = AppColors.success;
        label = 'Opened';
        icon = Icons.check_rounded;
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: state == _OpenState.idle ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
