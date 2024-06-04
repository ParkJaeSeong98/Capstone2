import 'package:flutter/material.dart';

class CustomSpinningWheel extends StatefulWidget {
  final double size;
  final Function onSpinComplete;
  final double spinSpeed;

  const CustomSpinningWheel({
    Key? key,
    required this.size,
    required this.onSpinComplete,
    this.spinSpeed = 1.0,
  }) : super(key: key);

  @override
  _CustomSpinningWheelState createState() => _CustomSpinningWheelState();
}

class _CustomSpinningWheelState extends State<CustomSpinningWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2), // 스핀 지속 시간
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSpinComplete();
      }
    });
    _animation = Tween<double>(begin: 0, end: 3).animate( // end = 스핀이 몇 바퀴 도는지
        CurvedAnimation(parent: _controller, curve: Curves.decelerate));
  }

  void _spinWheel() {
    _controller.reset();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _spinWheel,
      child: RotationTransition(
        turns: _animation,
        child: Image.asset(
          'assets/roulette.png',
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
