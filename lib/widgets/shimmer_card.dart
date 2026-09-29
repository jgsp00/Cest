import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ShimmerCard extends StatefulWidget {
  final Widget child;

  const ShimmerCard({super.key, required this.child});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _anim = Tween<double>(
      begin: -2,
      end: 3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, child) => ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment(_anim.value - 1, -0.3),
        end: Alignment(_anim.value, 0.3),
        colors: [kCard, Colors.white.withOpacity(0.04), kCard],
      ).createShader(bounds),
      blendMode: BlendMode.srcATop,
      child: child,
    ),
    child: widget.child,
  );
}
