import 'package:flutter/material.dart';

/// Uses bundled original 3D courier artwork. A vector fallback is retained
/// for development environments where the generated asset is unavailable.
class AliCourierIllustration extends StatelessWidget {
  const AliCourierIllustration({super.key, this.size = 210});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const RadialGradient(
        radius: .76,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, .68, 1],
      ).createShader(bounds),
      child: Image.asset('assets/courier_3d.webp',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) =>
          CustomPaint(painter: _CourierPainter())),
    ),
  );
}

class _CourierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 220, size.height / 220);
    final shadow = Paint()..color = const Color(0x55000000)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final dark = Paint()..color = const Color(0xFF26232B);
    final red = Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFF7985), Color(0xFFF91B36), Color(0xFFB9001C)],
      stops: [0, .46, 1]).createShader(const Rect.fromLTWH(38, 20, 165, 170));
    final helmet = Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFF8991), Color(0xFFFF2441), Color(0xFFB5001A)])
      .createShader(const Rect.fromLTWH(86, 15, 83, 64));
    final face = Paint()..shader = const RadialGradient(
      center: Alignment(-.3, -.5), radius: .9,
      colors: [Color(0xFFFFE6BA), Color(0xFFFFBD87), Color(0xFFDF865E)])
      .createShader(const Rect.fromLTWH(86, 26, 72, 72));
    final white = Paint()..color = Colors.white;
    final skin = Paint()..color = const Color(0xFFFFC28E);
    final outline = Paint()..color = const Color(0xFF83111F)..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawOval(const Rect.fromLTWH(18, 195, 186, 16), shadow);
    // Rear insulated delivery box.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(34, 86, 63, 68), const Radius.circular(12)), dark);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(39, 82, 60, 66), const Radius.circular(10)), red);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(46, 96, 46, 33), const Radius.circular(7)), white);
    final bagText = TextPainter(text: const TextSpan(text: 'ALI', style: TextStyle(color: Color(0xFFE50922), fontWeight: FontWeight.w900, fontSize: 18)), textDirection: TextDirection.ltr);
    bagText.layout(); bagText.paint(canvas, const Offset(52, 102));
    // Wheels and scooter body.
    canvas.drawCircle(const Offset(65, 183), 23, dark);
    canvas.drawCircle(const Offset(170, 183), 23, dark);
    canvas.drawCircle(const Offset(65, 183), 12, white);
    canvas.drawCircle(const Offset(170, 183), 12, white);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(59, 143, 126, 37), const Radius.circular(17)), red);
    canvas.drawPath(Path()..moveTo(112, 158)..lineTo(159, 130)..lineTo(188, 130)..lineTo(180, 166)..close(), red);
    canvas.drawPath(Path()..moveTo(160, 136)..lineTo(177, 91)..lineTo(184, 91), outline);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(174, 87, 20, 7), const Radius.circular(3)), dark);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(79, 125, 51, 19), const Radius.circular(8)), dark);
    // Rider jacket and arms.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(99, 79, 49, 62), const Radius.circular(18)), red);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(135, 94, 18, 38), const Radius.circular(9)), red);
    canvas.drawCircle(const Offset(153, 126), 9, skin);
    // Face and helmet.
    canvas.drawCircle(const Offset(120, 58), 32, face);
    canvas.drawArc(const Rect.fromLTWH(86, 22, 69, 49), 3.1, 3.2, true, helmet);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(105, 20, 52, 12), const Radius.circular(6)), helmet);
    canvas.drawCircle(const Offset(111, 60), 3, dark);
    canvas.drawCircle(const Offset(133, 60), 3, dark);
    canvas.drawArc(const Rect.fromLTWH(111, 62, 23, 16), .15, 2.7, false, outline);
    canvas.drawCircle(const Offset(87, 58), 12, dark);
    canvas.drawCircle(const Offset(87, 58), 6, red);
    // Soft specular highlights create a more dimensional illustrated look.
    canvas.drawArc(const Rect.fromLTWH(96, 27, 42, 24), 3.65, 1.4,
      false, Paint()..color = const Color(0xAAFFFFFF)
        ..style = PaintingStyle.stroke..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round);
    canvas.drawRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(68, 146, 103, 6), const Radius.circular(4)),
      Paint()..color = const Color(0x88FFFFFF));
    canvas.drawRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(45, 86, 44, 5), const Radius.circular(4)),
      Paint()..color = const Color(0x77FFFFFF));
    canvas.drawCircle(const Offset(65, 183), 6,
      Paint()..color = const Color(0xFFBFC2CC));
    canvas.drawCircle(const Offset(170, 183), 6,
      Paint()..color = const Color(0xFFBFC2CC));
    // Glossy reflections.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(103, 150, 50, 5), const Radius.circular(3)), white..color = const Color(0x88FFFFFF));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
