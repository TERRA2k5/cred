import 'package:cached_network_image/cached_network_image.dart';
import 'package:credd/Widgets/PromoBannerWidget.dart';
import 'package:credd/Widgets/TopBarWidget.dart';
import 'package:credd/bloc/SDUIBloc.dart';
import 'package:credd/bloc/SDUIEvent.dart';
import 'package:credd/bloc/SDUIState.dart';
import 'package:credd/models/StatementSummaryModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BalanceHeaderWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final StatementHeaderModel? header;

  const BalanceHeaderWidget({
    super.key,
    required this.data,
    this.header,
  });

  @override
  State<BalanceHeaderWidget> createState() => _BalanceHeaderWidgetState();
}

class _BalanceHeaderWidgetState extends State<BalanceHeaderWidget> {
  StatementTab _localTab = StatementTab.totalDue;
  late StatementHeaderModel _header;

  @override
  void initState() {
    super.initState();
    _header = widget.header ?? StatementHeaderModel.fromJson(widget.data);
  }

  @override
  void didUpdateWidget(covariant BalanceHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.header != null && widget.header != oldWidget.header) {
      _header = widget.header!;
    } else if (widget.data != oldWidget.data) {
      _header = StatementHeaderModel.fromJson(widget.data);
    }
  }

  void _onTabSelected(StatementTab tab) {
    setState(() => _localTab = tab);
    try {
      context.read<SDUIBloc>().add(SwitchStatementTab(tab));
    } catch (_) {

    }
  }

  void _showCtaFeedback(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '"$label" tapped (no deeplink in mock response)',
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    StatementTab activeTab = _localTab;
    try {
      final blocState = context.watch<SDUIBloc>().state;
      if (blocState is SDUILoaded) {
        activeTab = blocState.activeTab;
      }
    } catch (_) {
      activeTab = _localTab;
    }

    final summary = activeTab == StatementTab.totalDue
        ? _header.statement
        : _header.unbilled;

    return Stack(
      children: [
        Positioned.fill(
          child: _header.backgroundUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: _header.backgroundUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(color: Color(0xFFF7F5F2)),
                  errorWidget: (_, _, _) => const ColoredBox(color: Color(0xFFF7F5F2)),
                )
              : const ColoredBox(color: Color(0xFFF7F5F2)),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                TopBarWidget(
                  leftIconUrl: _header.leftIconUrl,
                  rightIconUrl: _header.rightIconUrl,
                  leftLabel: _header.statement.label,
                  rightLabel: _header.unbilled.label,
                  badgeCount: _header.statement.badgeCount,
                  selectedIndex: activeTab == StatementTab.totalDue ? 0 : 1,
                  onTabSelected: (index) {
                    _onTabSelected(
                      index == 0 ? StatementTab.totalDue : StatementTab.recentSpends,
                    );
                  },
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _SummaryBlock(
                    key: ValueKey<StatementTab>(activeTab),
                    summary: summary,
                    onCtaTap: () => _showCtaFeedback(context, summary.ctaTitle),
                  ),
                ),
                if (_header.offerProperties != null) ...[
                  const SizedBox(height: 14),
                  PromoBannerWidget(data: _header.offerProperties!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AmountText extends StatelessWidget {
  const AmountText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final dot = text.lastIndexOf('.');
    if (dot < 0) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, dot)),
          TextSpan(text: text.substring(dot)),
        ],
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  final StatementSummaryModel summary;
  final VoidCallback onCtaTap;

  const _SummaryBlock({
    super.key,
    required this.summary,
    required this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          summary.title,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A8A8A),
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AmountText(
                summary.amountText,
                style: const TextStyle(
                  fontFamily: 'BodoniModa',
                  letterSpacing: 1.2,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.black,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onCtaTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
              child: Text(
                summary.ctaTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
