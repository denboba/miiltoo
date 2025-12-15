import 'package:flutter/material.dart';
import '../config/design_constants.dart';

/// Skeleton loader widget for better loading states
/// Replaces spinners with content-aware loading placeholders
class LoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  
  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = DesignConstants.radiusMedium,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[300]?.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Skeleton for ride card
class RideCardSkeleton extends StatelessWidget {
  const RideCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignConstants.spaceMedium),
      child: Padding(
        padding: const EdgeInsets.all(DesignConstants.cardPaddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LoadingSkeleton(
                  width: DesignConstants.avatarSmall,
                  height: DesignConstants.avatarSmall,
                  borderRadius: DesignConstants.radiusCircle,
                ),
                const SizedBox(width: DesignConstants.spaceSmall),
                const Expanded(
                  child: LoadingSkeleton(width: 120, height: 16),
                ),
              ],
            ),
            const SizedBox(height: DesignConstants.spaceMedium),
            const LoadingSkeleton(width: double.infinity, height: 14),
            const SizedBox(height: DesignConstants.spaceSmall),
            const LoadingSkeleton(width: double.infinity, height: 14),
            const SizedBox(height: DesignConstants.spaceMedium),
            Row(
              children: [
                const LoadingSkeleton(width: 80, height: 12),
                const Spacer(),
                const LoadingSkeleton(width: 60, height: 24, borderRadius: DesignConstants.radiusSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list builder
class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  
  const SkeletonListView({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignConstants.spaceMedium),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
