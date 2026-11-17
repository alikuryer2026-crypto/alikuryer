import 'package:flutter/material.dart';

/// Approved ALIKURYER 16-screen design system.
abstract final class AliPalette {
  static const red = Color(0xFFE50922);
  static const deepRed = Color(0xFFB90019);
  static const ink = Color(0xFF17171D);
  static const canvas = Color(0xFFF7F7F9);
  static const softRed = Color(0xFFFFECEF);
}

class AliBrandHeader extends StatelessWidget {
  const AliBrandHeader({super.key, this.trailing});
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
    const Icon(Icons.delivery_dining_rounded, color: AliPalette.red, size: 31),
    const SizedBox(width: 6),
    const Text('Alikuryer', style: TextStyle(
      color: AliPalette.deepRed, fontSize: 23,
      fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
    const Spacer(),
    if (trailing != null) trailing!,
  ]);
}

class AliRedButton extends StatelessWidget {
  const AliRedButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AliPalette.red,
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 19)],
      ]),
    ),
  );
}

class AliSectionCard extends StatelessWidget {
  const AliSectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0x0B000000), blurRadius: 20, offset: Offset(0, 5))]),
    child: child,
  );
}
