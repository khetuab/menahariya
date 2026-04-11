// lib/modules/admin/widgets/admin_loading_shimmer.dart

import 'package:flutter/material.dart';

import '../../../../core/widgets/loading/shimmer_loading.dart';

class AdminLoadingShimmer extends StatelessWidget {
  const AdminLoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}