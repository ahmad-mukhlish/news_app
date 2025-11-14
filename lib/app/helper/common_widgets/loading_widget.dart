import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Semantics(
          label: "Loading",
          child: const CircularProgressIndicator(),
        ),
      );
}
