import 'package:cached_network_image/cached_network_image.dart';
import 'package:credd/Widgets/common/CtaFeedback.dart';
import 'package:credd/core/utils/JsonExt.dart';
import 'package:flutter/material.dart';

class TopBarWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String leftIconUrl;
  final String rightIconUrl;
  final String leftLabel;
  final String rightLabel;
  final int badgeCount;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const TopBarWidget({
    super.key,
    this.data,
    this.leftIconUrl = '',
    this.rightIconUrl = '',
    this.leftLabel = 'TOTAL DUE',
    this.rightLabel = 'RECENT SPENDS',
    this.badgeCount = 0,
    this.selectedIndex = 0,
    this.onTabSelected,
  });

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  late int _activeTabIndex;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant TopBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _activeTabIndex = widget.selectedIndex;
    }
  }

  void _onTabTapped(int index) {
    setState(() => _activeTabIndex = index);
    widget.onTabSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data != null) {
      final body = widget.data!.bodyOrSelf;
      final hasStatement = body.containsKey('statement') || body.containsKey('unbilled');
      if (!hasStatement) {
        return const SizedBox.shrink();
      }
    }

    final effectiveLeftUrl = widget.leftIconUrl;
    final effectiveRightUrl = widget.rightIconUrl;
    final effectiveLeftLabel = widget.leftLabel;
    final effectiveRightLabel = widget.rightLabel;
    final effectiveBadge = widget.badgeCount;

    return Row(
      children: [
        _buildHeaderIcon(effectiveLeftUrl, Icons.percent_rounded, 'offers'),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTabChip(
                      label: effectiveLeftLabel,
                      badge: effectiveBadge,
                      selected: _activeTabIndex == 0,
                      onTap: () => _onTabTapped(0),
                    ),
                    _buildTabChip(
                      label: effectiveRightLabel,
                      badge: 0,
                      selected: _activeTabIndex == 1,
                      onTap: () => _onTabTapped(1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildHeaderIcon(effectiveRightUrl, Icons.settings_outlined, 'settings'),
      ],
    );
  }

  Widget _buildHeaderIcon(String url, IconData fallback, String label) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showCtaFeedback(context, label),
      child: SizedBox.square(
        dimension: 40,
        child: url.isEmpty
            ? Icon(fallback, size: 32, color: Colors.black87)
            : Padding(
                padding: const EdgeInsets.all(4),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => Icon(fallback, size: 32, color: Colors.black87),
                ),
              ),
      ),
    );
  }

  Widget _buildTabChip({
    required String label,
    required int badge,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.black : const Color(0xFF9A9A9A),
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 14,
                height: 14,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5483B),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
