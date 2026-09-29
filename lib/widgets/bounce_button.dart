import 'package:flutter/material.dart';

class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;

  const BounceButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.color,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _tap,
    child: AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.color.withOpacity(0.35)),
          ),
          child: Center(child: child),
        ),
      ),
      child: widget.child,
    ),
  );
}
