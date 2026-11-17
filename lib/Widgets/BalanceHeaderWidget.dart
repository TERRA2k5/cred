import 'package:cached_network_image/cached_network_image.dart';
import 'package:credd/Widgets/PromoBannerWidget.dart';
import 'package:credd/Widgets/TopBarWidget.dart';
import 'package:flutter/material.dart';

class BalanceHeaderWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const BalanceHeaderWidget({super.key, required this.data});

  @override
  State<BalanceHeaderWidget> createState() => _BalanceHeaderWidgetState();
}

class _BalanceHeaderWidgetState extends State<BalanceHeaderWidget> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final body = widget.data['body'] is Map<String, dynamic>
        ? widget.data['body'] as Map<String, dynamic>
        : widget.data;

    final asset1 = body['asset_1'] is Map<String, dynamic>
        ? body['asset_1'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final bgUrl = asset1['url'] is String ? asset1['url'] as String : '';

    final statement = body['statement'] is Map<String, dynamic>
        ? body['statement'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final unbilled = body['unbilled'] is Map<String, dynamic>
        ? body['unbilled'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final isTotalDue = _activeTabIndex == 0;
    final activeSummary = isTotalDue ? statement : unbilled;

    final titleText = activeSummary['text_1'] is String && (activeSummary['text_1'] as String).isNotEmpty
        ? activeSummary['text_1'] as String
        : (isTotalDue ? 'STATEMENT DUE FOR 1 CARD' : 'RECENT SPENDS');
    final amountText = activeSummary['text_2'] is String && (activeSummary['text_2'] as String).isNotEmpty
        ? activeSummary['text_2'] as String
        : (isTotalDue ? '₹50,000.00' : '₹0.00');

    final cta2 = activeSummary['cta_2'] is Map<String, dynamic>
        ? activeSummary['cta_2'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final ctaTitle = cta2['title'] is String && (cta2['title'] as String).isNotEmpty
        ? cta2['title'] as String
        : (isTotalDue ? 'Pay bill' : 'View transactions');

    Map<String, dynamic>? offerProperties;
    final childList = widget.data['child_list'] is List
        ? widget.data['child_list'] as List
        : (body['child_list'] is List ? body['child_list'] as List : const []);
    for (final child in childList) {
      if (child is Map<String, dynamic> &&
          child['template_name'] == 'unbilled_statement_info_section_offer_2') {
        offerProperties = child['template_properties'] is Map<String, dynamic>
            ? child['template_properties'] as Map<String, dynamic>
            : null;
        break;
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: bgUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: bgUrl,
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
                TopBarWidget.fromData(
                  widget.data,
                  selectedIndex: _activeTabIndex,
                  onTabSelected: (index) {
                    setState(() => _activeTabIndex = index);
                  },
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    key: ValueKey<int>(_activeTabIndex),
                    children: [
                      Text(
                        titleText,
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            amountText,
                            style: const TextStyle(
                              fontSize: 30,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.black,
                        shape: const StadiumBorder(),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text('"$ctaTitle" tapped (no deeplink in mock response)'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(milliseconds: 1500),
                                ),
                              );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
                            child: Text(
                              ctaTitle,
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
                  ),
                ),
                if (offerProperties != null) ...[
                  const SizedBox(height: 14),
                  PromoBannerWidget(data: offerProperties),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
