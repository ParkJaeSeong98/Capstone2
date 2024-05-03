import 'package:flutter/material.dart';

class HealthMode extends InheritedWidget {
  final bool isHealthMode;
  final VoidCallback toggleHealthMode;

  const HealthMode({
    Key? key,
    required this.isHealthMode,
    required this.toggleHealthMode,
    required Widget child,
  }) : super(key: key, child: child);

  static HealthMode? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HealthMode>();
  }

  @override
  bool updateShouldNotify(HealthMode oldWidget) {
    return isHealthMode != oldWidget.isHealthMode;
  }
}