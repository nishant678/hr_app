import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class AppLoading extends StatelessWidget {
  final double height;
  final double width;

  const AppLoading({
    super.key,
    this.height = 100,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: CardShimmer(),
    );
  }
}
