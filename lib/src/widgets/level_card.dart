import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
  });

  final ValueNotifier<int> level;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: level,
      builder: (context, level, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
          child: Text(
            'Level:$level'.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge!,
          ),
        );
      },
    );
  }
}