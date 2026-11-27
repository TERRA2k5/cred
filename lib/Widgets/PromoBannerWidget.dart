import 'package:cached_network_image/cached_network_image.dart';
import 'package:credd/Widgets/common/CtaFeedback.dart';
import 'package:credd/core/utils/JsonExt.dart';
import 'package:credd/core/utils/MarkupParser.dart';
import 'package:flutter/material.dart';

class PromoBannerWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const PromoBannerWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final body = data.bodyOrSelf;
    final iconUrl = body.assetUrl('asset');

    final flipperList = body.list('flipper_config');
    final firstItem =
        flipperList.isNotEmpty && flipperList.first is Map<String, dynamic>
            ? flipperList.first as Map<String, dynamic>
            : const <String, dynamic>{};

    final rawText = firstItem.str('text_1', body.str('text_1'));

    if (rawText.isEmpty && iconUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final segments = MarkupParser.parse(rawText);

    return Center(
      child: GestureDetector(
        onTap: () => showCtaFeedback(context, 'Offer'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconUrl.isNotEmpty) ...[
                CachedNetworkImage(
                  imageUrl: iconUrl,
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => const Icon(
                    Icons.local_offer_outlined,
                    size: 14,
                    color: Color(0xFF6A3C6A),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text.rich(
                  MarkupParser.buildTextSpan(
                    segments,
                    defaultStyle: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.black87,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w500,
                    ),
                    boldAmounts: true,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 14, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }
}
