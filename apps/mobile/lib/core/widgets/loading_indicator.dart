// core/widgets/loading_indicator.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/widgets/loader_icon.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoaderIcon(
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}