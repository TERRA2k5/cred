import 'package:cached_network_image/cached_network_image.dart';
import 'package:credd/Widgets/common/AmountText.dart';
import 'package:credd/models/CreditCardModel.dart';
import 'package:flutter/material.dart';

class CreditCardItemView extends StatelessWidget {
  const CreditCardItemView({
    super.key,
    required this.card,
    this.detailsOpacity = kAlwaysCompleteAnimation,
    this.showShadow = true,
  });

  final CreditCardModel card;
  final Animation<double> detailsOpacity;
  final bool showShadow;

  static const _radius = BorderRadius.all(Radius.circular(12));
  static const _bevel = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0, 0.015, 0.04, 0.93, 0.975, 1],
      colors: [
        Color(0x66FFFFFF),
        Color(0x26FFFFFF),
        Color(0x00FFFFFF),
        Color(0x00000000),
        Color(0x26000000),
        Color(0x66000000),
      ],
    ),
  );
  static const _shadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8)),
  ];

  @override
  Widget build(BuildContext context) {
    final foreground = card.isLight ? Colors.black87 : Colors.white;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: showShadow ? _shadow : null,
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final inset = w * 0.075;
            return Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: card.artUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(color: Color(0xFF2E2E30)),
                  errorWidget: (_, _, _) => const ColoredBox(color: Color(0xFF2E2E30)),
                ),
                const IgnorePointer(child: DecoratedBox(decoration: _bevel)),
                FadeTransition(
                  opacity: detailsOpacity,
                  child: Stack(
                    children: [
                      Positioned(
                        left: inset,
                        top: h * 0.215,
                        child: Text(
                          card.maskedNumber,
                          style: TextStyle(
                            color: foreground.withValues(alpha: 0.85),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (card.amountText != null)
                        Positioned(
                          right: inset,
                          top: h * 0.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AmountText(
                                card.amountText!,
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              if (card.dueText != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  card.dueText!,
                                  style: TextStyle(
                                    color: foreground.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      else if (card.networkLogoUrl != null)
                        Positioned(
                          right: inset,
                          top: h * 0.1,
                          child: CachedNetworkImage(
                            imageUrl: card.networkLogoUrl!,
                            height: h * 0.12,
                          ),
                        ),
                      Positioned(
                        left: inset,
                        bottom: h * 0.11,
                        child: Text(
                          card.holderName.toUpperCase(),
                          style: TextStyle(
                            color: foreground,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      Positioned(
                        right: inset,
                        bottom: h * 0.09,
                        child: _PayNowButton(title: card.payCtaTitle),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PayNowButton extends StatelessWidget {
  const _PayNowButton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => showCtaFeedback(context, title),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
