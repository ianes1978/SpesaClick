import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/chain.dart';
import '../providers.dart';

/// Scelta della catena in cui si fa la spesa.
class ChainSwitcher extends ConsumerWidget {
  const ChainSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(activeChainProvider);
    final color = Theme.of(context).colorScheme.onPrimary;
    return PopupMenuButton<Chain>(
      tooltip: 'Catena',
      initialValue: chain,
      onSelected: ref.read(activeChainProvider.notifier).set,
      itemBuilder: (_) => [
        for (final c in Chain.values)
          PopupMenuItem(
            value: c,
            child: ListTile(
              leading: Icon(c == chain
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off),
              title: Text(c.label),
              subtitle: Text(c.serviceName),
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(chain.label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Icon(Icons.arrow_drop_down, color: color),
        ]),
      ),
    );
  }
}

/// Avviso: i prezzi Click&Coop sono quelli del listino online.
class CoopPriceNotice extends StatelessWidget {
  const CoopPriceNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: cs.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Prezzi del listino online Click&Coop, in negozio possono differire.',
        style: TextStyle(color: cs.onSecondaryContainer, fontSize: 12),
      ),
    );
  }
}
