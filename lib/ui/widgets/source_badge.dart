import 'package:flutter/material.dart';

import '../../domain/chain.dart';
import '../../domain/price_quote.dart';
import 'format.dart';

class SourceBadge extends StatelessWidget {
  const SourceBadge(this.quote, {super.key});

  final PriceQuote quote;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (quote.source) {
      PriceSource.store => (cs.primaryContainer, cs.onPrimaryContainer),
      PriceSource.online => (cs.secondaryContainer, cs.onSecondaryContainer),
      PriceSource.label => (cs.tertiaryContainer, cs.onTertiaryContainer),
      PriceSource.offline => (cs.surfaceContainerHighest, cs.onSurfaceVariant),
    };
    var text = quote.source == PriceSource.offline
        ? 'offline · ${shortDate(quote.readAt)}'
        : quote.source.badge;
    if (quote.chain == Chain.coop) text = 'Coop · $text';
    if (quote.chain.isEverli) {
      text = '${quote.chain.label} · Everli ${shortDate(quote.readAt)}';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}
