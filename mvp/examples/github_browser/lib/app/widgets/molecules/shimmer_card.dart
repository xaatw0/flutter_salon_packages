import 'package:flutter/material.dart';

import '../atoms/shimmer_widget.dart';

/// RepositoryDataCardに似ているローディングしている最中に表示するWidget
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: ShimmerWidget.circular(
            width: 52,
            height: 52,
            shapeBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          title: const ShimmerWidget.rectangular(height: 32),
        ),
      ),
    );
  }
}
