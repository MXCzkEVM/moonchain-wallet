import 'package:flutter/material.dart';

class Flat extends StatelessWidget {
  const Flat({
    Key? key,
    required this.builders,
    required this.child,
  }) : super(key: key);

  final List<Widget Function(Widget)> builders;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var child = this.child;
    for (var newChildBuilder in builders) {
      child = newChildBuilder(child);
    }
    return child;
  }
}
