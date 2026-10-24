import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage(this.url, {super.key, this.size = 56});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.shopping_basket_outlined,
      size: size * 0.5,
      color: Theme.of(context).colorScheme.outline,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        alignment: Alignment.center,
        child: url == null
            ? fallback
            : Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
