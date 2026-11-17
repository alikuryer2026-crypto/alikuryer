import 'package:flutter/material.dart';

/// Decorative map for design previews only. This is NOT a live GPS map.
class AliMapPreview extends StatelessWidget {
  const AliMapPreview({super.key, this.showCourier = false, this.height = 245});
  final bool showCourier;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFFE9F0EB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE1E9E5))),
    child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _PreviewMapPainter())),
      const Positioned(top: 10, left: 10, child: _MapLabel('Xarita namunasi')),
      const Align(alignment: Alignment(0.64, -0.52),
        child: Icon(Icons.location_on, color: Color(0xFFE50922), size: 39)),
      if (showCourier)
        const Align(alignment: Alignment(-0.35, 0.40),
          child: CircleAvatar(radius: 20, backgroundColor: Colors.white,
            child: Icon(Icons.delivery_dining, color: Color(0xFFE50922), size: 26))),
      Positioned(right: 10, bottom: 10, child: Column(children: [
        _MapControl(icon: Icons.add),
        const SizedBox(height: 6),
        _MapControl(icon: Icons.remove),
      ])),
      const Positioned(left: 10, bottom: 10,
        child: _MapLabel('GPS keyin ulanadi')),
    ]),
  );
}

class _MapLabel extends StatelessWidget {
  const _MapLabel(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 7)]),
    child: Text(value, style: const TextStyle(fontSize: 10,
      fontWeight: FontWeight.w700, color: Color(0xFF4C5D53))),
  );
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(9)),
    child: Icon(icon, size: 19, color: const Color(0xFF45584E)),
  );
}

class _PreviewMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final park = Paint()..color = const Color(0xFFD7E8D5);
    final block = Paint()..color = const Color(0xFFF8F7F0);
    final road = Paint()..color = Colors.white..strokeWidth = 11
      ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final avenue = Paint()..color = const Color(0xFFFFE1A7)..strokeWidth = 8
      ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final route = Paint()..color = const Color(0xFFE50922)..strokeWidth = 4
      ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, block);
    for (var i = 0; i < 9; i++) {
      final x = (i * 73.0) % (size.width + 65) - 15;
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x, (i * 39.0) % size.height, 48, 54),
        const Radius.circular(9)), park);
    }
    for (var i = -3; i < 13; i++) {
      final x = i * 44.0;
      canvas.drawLine(Offset(x, 0), Offset(x + 65, size.height), road);
    }
    for (var i = 0; i < 8; i++) {
      final y = i * 41.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 16), road);
    }
    canvas.drawLine(Offset(0, size.height * .69),
      Offset(size.width, size.height * .30), avenue);
    final p = Path()
      ..moveTo(size.width * .18, size.height * .78)
      ..lineTo(size.width * .30, size.height * .65)
      ..lineTo(size.width * .42, size.height * .65)
      ..lineTo(size.width * .58, size.height * .38)
      ..lineTo(size.width * .73, size.height * .30);
    canvas.drawPath(p, route);
    canvas.drawCircle(Offset(size.width * .18, size.height * .78), 7,
      Paint()..color = const Color(0xFFE50922));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
