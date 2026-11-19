import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reference_design.dart';
import 'courier_illustration.dart';

/// Visual prototype. Authentication is deliberately NOT connected yet.
/// All steps work locally so the approved design can be reviewed first.
class AliOnboarding extends StatefulWidget {
  const AliOnboarding({super.key, required this.onFinish});
  final VoidCallback onFinish;
  @override
  State<AliOnboarding> createState() => _AliOnboardingState();
}

class _AliOnboardingState extends State<AliOnboarding> {
  int step = 0;
  int language = 0;
  String? error;
  final phone = TextEditingController();
  final code = TextEditingController();
  static const red = AliPalette.red;
  static const langs = [
    ('🇺🇿', 'O‘zbekcha', 'O‘zbek tili'),
    ('🇷🇺', 'Русский', 'Русский язык'),
    ('🇬🇧', 'English', 'English language'),
    ('🇨🇳', '中文 (简体)', '简体中文'),
  ];

  @override
  void dispose() {
    phone.dispose();
    code.dispose();
    super.dispose();
  }

  void advance() {
    FocusScope.of(context).unfocus();
    if (step == 2 && phone.text.replaceAll(RegExp(r'\D'), '').length != 9) {
      setState(() => error = '9 xonali telefon raqamini kiriting');
      return;
    }
    if (step == 3) {
      widget.onFinish();
      return;
    }
    setState(() { step++; error = null; });
  }

  Widget courier(double size) => Center(child: AliCourierIllustration(size: size));

  Widget splashArtwork(double height) => SizedBox(
    height: height,
    width: double.infinity,
    child: Stack(fit: StackFit.expand, children: [
      Positioned.fill(child: CustomPaint(painter: _UzbekSkylinePainter())),
      Align(alignment: const Alignment(0, 0.10),
        child: AliCourierIllustration(size: height * 1.02)),
    ]),
  );

  Widget headline(String title, String subtitle) => Column(children: [
    Text(title, textAlign: TextAlign.center, style: const TextStyle(
      fontSize: 27, height: 1.12, fontWeight: FontWeight.w900, color: AliPalette.ink)),
    const SizedBox(height: 9),
    Text(subtitle, textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, height: 1.45, color: Colors.black54)),
  ]);

  Widget languageCard(int i) {
    final selected = language == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? const Color(0xFFFFF2F4) : Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => setState(() => language = i),
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: selected ? red : const Color(0xFFE9E9ED),
                width: selected ? 2 : 1)),
            child: Row(children: [
              Text(langs[i].$1, style: const TextStyle(fontSize: 27)),
              const SizedBox(width: 14),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(langs[i].$2, style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
                Text(langs[i].$3, style: const TextStyle(
                  fontSize: 11, color: Colors.black45)),
              ])),
              if (selected) const CircleAvatar(radius: 14, backgroundColor: red,
                child: Icon(Icons.check, size: 19, color: Colors.white))
              else const Icon(Icons.circle_outlined, color: Color(0xFFD0D0D4)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget phoneStep() => Column(children: [
    courier(205),
    const SizedBox(height: 7),
    headline('Telefon raqamingiz', 'Davom etish uchun telefon raqamingizni kiriting'),
    const SizedBox(height: 26),
    TextField(
      controller: phone,
      keyboardType: TextInputType.phone,
      maxLength: 9,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone_iphone, color: red),
        prefixText: '+998  ',
        counterText: '',
        hintText: '90 123 45 67',
        filled: true,
        fillColor: const Color(0xFFF8F8FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFE6E6E9))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFE6E6E9))),
      ),
    ),
    const SizedBox(height: 20),
    const Text('Yoki boshqa usulda kirish', style: TextStyle(color: Colors.black45)),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: null,
        icon: const Icon(Icons.g_mobiledata, size: 28), label: const Text('Google'))),
      const SizedBox(width: 12),
      Expanded(child: OutlinedButton.icon(onPressed: null,
        icon: const Icon(Icons.apple), label: const Text('Apple'))),
    ]),
    const SizedBox(height: 12),
    const Text('Bu dizayn namunasidir. SMS va ijtimoiy kirish keyin ulanadi.',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black45)),
  ]);

  Widget otpStep() => Column(children: [
    courier(190),
    const SizedBox(height: 12),
    headline('Tasdiqlash kodi', 'SMS tasdiqlash dizayni — hozircha demo rejimi'),
    const SizedBox(height: 12),
    Text('+998 ${phone.text}', style: const TextStyle(
      fontWeight: FontWeight.w800, color: red)),
    const SizedBox(height: 26),
    TextField(
      controller: code,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: '●  ●  ●  ●  ●  ●',
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF8F8FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17)),
      ),
    ),
    const SizedBox(height: 14),
    const Text('Haqiqiy SMS yuborilmaydi. Davom etish — dizaynni ko‘rish.',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black45)),
  ]);

  @override
  Widget build(BuildContext context) {
    final splash = step == 0;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: splash ? const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            stops: [0, .30, .65, 1],
            colors: [Color(0xFF171B2E), Color(0xFF54202B),
              Color(0xFFBA001B), Color(0xFF940013)]) : null,
          color: splash ? null : Colors.white),
        child: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: Column(children: [
          Row(children: [
            if (!splash) IconButton(
              onPressed: () => setState(() { step--; error = null; }),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20))
            else const SizedBox(width: 48),
            const Spacer(),
            Text('Alikuryer', style: TextStyle(
              color: splash ? Colors.white : red, fontSize: 27,
              fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
            const Spacer(),
            const SizedBox(width: 48),
          ]),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              if (splash) ...[
                SizedBox(height: height < 700 ? 6 : 14),
                splashArtwork((height * .47).clamp(275.0, 480.0)),
                const SizedBox(height: 20),
                const Text('Hamma narsa\nsiz uchun!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 35, height: 1.1,
                    fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 12),
                const Text('Sevimli taomlaringizni tez, qulay va\nishonchli yetkazib beramiz!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
              ],
              if (step == 1) ...[
                const SizedBox(height: 10),
                headline('Tilni tanlang', 'O‘zingizga qulay tilni tanlang'),
                const SizedBox(height: 7),
                courier(height < 700 ? 110 : 155),
                const SizedBox(height: 12),
                for (var i = 0; i < langs.length; i++) languageCard(i),
              ],
              if (step == 2) phoneStep(),
              if (step == 3) otpStep(),
            ]),
          )),
          if (error != null) Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(error!, textAlign: TextAlign.center,
              style: const TextStyle(color: red, fontWeight: FontWeight.w700))),
          if (splash) const Padding(
            padding: EdgeInsets.only(bottom: 13),
            child: Text('●  ○  ○  ○', style: TextStyle(color: Colors.white))),
          AliRedButton(
            label: step == 0 ? 'Boshlash' : step == 1 ? 'Davom etish'
              : step == 2 ? 'Keyingi qadam (demo)' : 'Ilovani ko‘rish',
            icon: Icons.arrow_forward_rounded,
            onPressed: advance),
          if (step >= 2) TextButton(
            onPressed: widget.onFinish,
            child: const Text('Dizaynni kirishsiz ko‘rish')),
        ]),
      ))),
    );
  }
}

class _UzbekSkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x668DD0E0);
    final glow = Paint()..color = const Color(0x339CE4FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 19);
    canvas.drawCircle(Offset(size.width * .22, size.height * .35),
      size.width * .28, glow);
    canvas.drawCircle(Offset(size.width * .79, size.height * .28),
      size.width * .24, glow);
    final ground = Paint()..color = const Color(0x668A1027);
    canvas.drawRect(Rect.fromLTWH(0, size.height * .85, size.width, size.height * .15), ground);
    for (final x in [.08, .78]) {
      final left = size.width * x;
      final top = size.height * .27;
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, size.width * .095, size.height * .54),
        const Radius.circular(5)), paint);
      final spire = Path()
        ..moveTo(left, top)
        ..lineTo(left + size.width * .0475, top - size.height * .14)
        ..lineTo(left + size.width * .095, top)
        ..close();
      canvas.drawPath(spire, paint);
    }
    final center = Offset(size.width * .24, size.height * .57);
    final dome = Path()
      ..moveTo(center.dx - size.width * .19, center.dy)
      ..quadraticBezierTo(center.dx - size.width * .16, center.dy - size.height * .32,
        center.dx, center.dy - size.height * .30)
      ..quadraticBezierTo(center.dx + size.width * .16, center.dy - size.height * .32,
        center.dx + size.width * .19, center.dy)
      ..close();
    canvas.drawPath(dome, Paint()..color = const Color(0x7774C7D8));
    canvas.drawRect(Rect.fromLTWH(center.dx - size.width * .20, center.dy,
      size.width * .40, size.height * .27), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
