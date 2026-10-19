import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum ArtefactType {
  lotus,
  crown,
  neck,
  vase,
  robe,
  fan,
  box,
  chair,
  ear,
}

class ArtefactArt extends StatelessWidget {
  const ArtefactArt({
    super.key,
    required this.type,
    this.size = 140,
    this.rotationAngle = 0.0,
    this.hasDropShadow = true,
  });

  final ArtefactType type;
  final double size;
  final double rotationAngle;
  final bool hasDropShadow;

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      size: Size(size, size),
      painter: _ArtefactPainter(type: type, angle: rotationAngle),
    );

    if (hasDropShadow) {
      content = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0x3D5A3C14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: content,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: content),
    );
  }
}

class _ArtefactPainter extends CustomPainter {
  _ArtefactPainter({required this.type, required this.angle});

  final ArtefactType type;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Allow slight rotation if specified (e.g. 360 viewer or sway)
    if (angle != 0) {
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(angle);
      canvas.translate(-size.width / 2, -size.height / 2);
    }

    final sx = size.width / 200.0;
    final sy = size.height / 200.0;

    switch (type) {
      case ArtefactType.lotus:
        _paintLotus(canvas, size, sx, sy);
        break;
      case ArtefactType.crown:
        _paintCrown(canvas, size, sx, sy);
        break;
      case ArtefactType.neck:
        _paintNecklace(canvas, size, sx, sy);
        break;
      case ArtefactType.vase:
        _paintVase(canvas, size, sx, sy);
        break;
      case ArtefactType.robe:
        _paintRobe(canvas, size, sx, sy);
        break;
      case ArtefactType.fan:
        _paintFan(canvas, size, sx, sy);
        break;
      case ArtefactType.box:
        _paintBox(canvas, size, sx, sy);
        break;
      case ArtefactType.chair:
        _paintChair(canvas, size, sx, sy);
        break;
      case ArtefactType.ear:
        _paintEarrings(canvas, size, sx, sy);
        break;
    }

    canvas.restore();
  }

  void _paintCrown(Canvas canvas, Size size, double sx, double sy) {
    final goldGrad = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF7E6C4), OriginColors.gold, OriginColors.goldDark],
    ).createShader(Rect.fromLTWH(20 * sx, 30 * sy, 160 * sx, 150 * sy));

    final goldPaint = Paint()..shader = goldGrad;
    final outlinePaint = Paint()
      ..color = const Color(0xFF8A642F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * sx;

    // Crown peaks: M30 140 22 70 66 100 100 46 134 100 178 70 170 140Z
    final bodyPath = Path()
      ..moveTo(30 * sx, 140 * sy)
      ..lineTo(22 * sx, 70 * sy)
      ..lineTo(66 * sx, 100 * sy)
      ..lineTo(100 * sx, 46 * sy)
      ..lineTo(134 * sx, 100 * sy)
      ..lineTo(178 * sx, 70 * sy)
      ..lineTo(170 * sx, 140 * sy)
      ..close();

    canvas.drawPath(bodyPath, goldPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Crown base band: rect x="28" y="140" width="144" height="22" rx="4"
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(28 * sx, 140 * sy, 144 * sx, 22 * sy),
      Radius.circular(4 * sx),
    );
    canvas.drawRRect(baseRect, goldPaint);
    canvas.drawRRect(baseRect, outlinePaint);

    // Jewels on peaks
    final pearlPaint = Paint()..color = Colors.white;
    final blushJewel = Paint()..color = OriginColors.blush;
    final emeraldPaint = Paint()..color = const Color(0xFF3F7A5C);
    final lavenderPaint = Paint()..color = OriginColors.lavender;

    // Center jewel
    canvas.drawCircle(Offset(100 * sx, 42 * sy), 8 * sx, blushJewel);
    canvas.drawCircle(Offset(100 * sx, 42 * sy), 8 * sx, outlinePaint);

    // Side pearls
    canvas.drawCircle(Offset(22 * sx, 66 * sy), 6 * sx, pearlPaint);
    canvas.drawCircle(Offset(22 * sx, 66 * sy), 6 * sx, outlinePaint);
    canvas.drawCircle(Offset(178 * sx, 66 * sy), 6 * sx, pearlPaint);
    canvas.drawCircle(Offset(178 * sx, 66 * sy), 6 * sx, outlinePaint);

    // Center body jewel
    canvas.drawCircle(Offset(100 * sx, 100 * sy), 9 * sx, emeraldPaint);
    canvas.drawCircle(Offset(100 * sx, 100 * sy), 9 * sx, outlinePaint);

    // Base band jewels
    canvas.drawCircle(Offset(100 * sx, 151 * sy), 7 * sx, emeraldPaint);
    canvas.drawCircle(Offset(64 * sx, 151 * sy), 5 * sx, lavenderPaint);
    canvas.drawCircle(Offset(136 * sx, 151 * sy), 5 * sx, lavenderPaint);
  }

  void _paintNecklace(Canvas canvas, Size size, double sx, double sy) {
    final goldGrad = const LinearGradient(
      colors: [Color(0xFFF1DCAE), OriginColors.gold, OriginColors.goldDark],
    ).createShader(Rect.fromLTWH(20 * sx, 20 * sy, 160 * sx, 160 * sy));

    final strand1 = Paint()
      ..shader = goldGrad
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * sx
      ..strokeCap = StrokeCap.round;

    final strand2 = Paint()
      ..shader = goldGrad
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * sx
      ..strokeCap = StrokeCap.round;

    final outline = Paint()
      ..color = const Color(0xFF8A642F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * sx;

    // Strands: M24 40C30 130 170 130 176 40
    final p1 = Path()
      ..moveTo(24 * sx, 40 * sy)
      ..cubicTo(30 * sx, 130 * sy, 170 * sx, 130 * sy, 176 * sx, 40 * sy);
    canvas.drawPath(p1, strand1);

    // Inner strand: M44 62C60 112 140 112 156 62
    final p2 = Path()
      ..moveTo(44 * sx, 62 * sy)
      ..cubicTo(60 * sx, 112 * sy, 140 * sx, 112 * sy, 156 * sx, 62 * sy);
    canvas.drawPath(p2, strand2);

    // Kundan emerald pendants
    final emeraldPaint = Paint()..color = const Color(0xFF3F7A5C);

    // Center pendant: 100 118, 84 150, 100 176, 116 150
    final pendCenter = Path()
      ..moveTo(100 * sx, 118 * sy)
      ..lineTo(84 * sx, 150 * sy)
      ..lineTo(100 * sx, 176 * sy)
      ..lineTo(116 * sx, 150 * sy)
      ..close();
    canvas.drawPath(pendCenter, emeraldPaint);
    canvas.drawPath(pendCenter, outline);

    // Left pendant: 70 106, 58 128, 70 146, 82 128
    final pendLeft = Path()
      ..moveTo(70 * sx, 106 * sy)
      ..lineTo(58 * sx, 128 * sy)
      ..lineTo(70 * sx, 146 * sy)
      ..lineTo(82 * sx, 128 * sy)
      ..close();
    canvas.drawPath(pendLeft, emeraldPaint);
    canvas.drawPath(pendLeft, outline);

    // Right pendant: 130 106, 118 128, 130 146, 142 128
    final pendRight = Path()
      ..moveTo(130 * sx, 106 * sy)
      ..lineTo(118 * sx, 128 * sy)
      ..lineTo(130 * sx, 146 * sy)
      ..lineTo(142 * sx, 128 * sy)
      ..close();
    canvas.drawPath(pendRight, emeraldPaint);
    canvas.drawPath(pendRight, outline);

    // Pearls
    final pearl = Paint()..color = Colors.white;
    final pearlBorder = Paint()
      ..color = const Color(0xFFC9B48C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * sx;

    for (final pt in [
      Offset(40 * sx, 70 * sy),
      Offset(52 * sx, 92 * sy),
      Offset(160 * sx, 70 * sy),
      Offset(148 * sx, 92 * sy),
      Offset(100 * sx, 184 * sy),
    ]) {
      canvas.drawCircle(pt, 5 * sx, pearl);
      canvas.drawCircle(pt, 5 * sx, pearlBorder);
    }
  }

  void _paintVase(Canvas canvas, Size size, double sx, double sy) {
    final porcelainPaint = Paint()..color = const Color(0xFFF6F3EA);
    final goldBorder = Paint()
      ..color = OriginColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * sx;

    final cobaltPaint = Paint()
      ..color = const Color(0xFF4A6FA5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * sx
      ..strokeCap = StrokeCap.round;

    // Body: M80 24H120V44C118 60 150 80 150 120 150 160 130 180 100 180 70 180 50 160 50 120 50 80 82 60 80 44Z
    final vasePath = Path()
      ..moveTo(80 * sx, 24 * sy)
      ..lineTo(120 * sx, 24 * sy)
      ..lineTo(120 * sx, 44 * sy)
      ..cubicTo(118 * sx, 60 * sy, 150 * sx, 80 * sy, 150 * sx, 120 * sy)
      ..cubicTo(150 * sx, 160 * sy, 130 * sx, 180 * sy, 100 * sx, 180 * sy)
      ..cubicTo(70 * sx, 180 * sy, 50 * sx, 160 * sy, 50 * sx, 120 * sy)
      ..cubicTo(50 * sx, 80 * sy, 82 * sx, 60 * sy, 80 * sx, 44 * sy)
      ..close();

    canvas.drawPath(vasePath, porcelainPaint);
    canvas.drawPath(vasePath, goldBorder);

    // Cobalt wave bands
    canvas.drawLine(Offset(52 * sx, 112 * sy), Offset(148 * sx, 112 * sy), cobaltPaint);
    canvas.drawLine(Offset(56 * sx, 140 * sy), Offset(144 * sx, 140 * sy), cobaltPaint);

    // Decorative arcs
    final arc1 = Path()
      ..moveTo(76 * sx, 84 * sy)
      ..cubicTo(90 * sx, 100 * sy, 110 * sx, 100 * sy, 124 * sx, 84 * sy);
    canvas.drawPath(arc1, cobaltPaint);

    // Gold rim: M78 30H122
    final rimPaint = Paint()
      ..color = OriginColors.gold
      ..strokeWidth = 6 * sx
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(78 * sx, 30 * sy), Offset(122 * sx, 30 * sy), rimPaint);
  }

  void _paintFan(Canvas canvas, Size size, double sx, double sy) {
    final blushSilk = Paint()..color = OriginColors.blush;
    final goldOutline = Paint()
      ..color = OriginColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * sx;

    // Fan fan-out: M100 170 20 70C60 30 140 30 180 70Z
    final fanPath = Path()
      ..moveTo(100 * sx, 170 * sy)
      ..lineTo(20 * sx, 70 * sy)
      ..cubicTo(60 * sx, 30 * sy, 140 * sx, 30 * sy, 180 * sx, 70 * sy)
      ..close();

    canvas.drawPath(fanPath, blushSilk);
    canvas.drawPath(fanPath, goldOutline);

    // Spokes
    final ribPaint = Paint()
      ..color = OriginColors.goldDark
      ..strokeWidth = 1.4 * sx;

    final endpoints = [
      Offset(46 * sx, 44 * sy),
      Offset(72 * sx, 36 * sy),
      Offset(100 * sx, 32 * sy),
      Offset(128 * sx, 36 * sy),
      Offset(154 * sx, 44 * sy),
    ];
    for (final ep in endpoints) {
      canvas.drawLine(Offset(100 * sx, 170 * sy), ep, ribPaint);
    }

    // Outer rim curve
    final rimPath = Path()
      ..moveTo(20 * sx, 70 * sy)
      ..cubicTo(60 * sx, 30 * sy, 140 * sx, 30 * sy, 180 * sx, 70 * sy);
    final rimPaint = Paint()
      ..color = OriginColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * sx;
    canvas.drawPath(rimPath, rimPaint);

    // Pivot rivet
    canvas.drawCircle(Offset(100 * sx, 170 * sy), 6 * sx, Paint()..color = OriginColors.goldDark);
  }

  void _paintRobe(Canvas canvas, Size size, double sx, double sy) {
    final lavenderSilk = Paint()..color = OriginColors.lavender;
    final robeOutline = Paint()
      ..color = const Color(0xFF7D6AA6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * sx;

    // Robe shape: M70 20 100 40 130 20 190 80 164 108 146 92V184H54V92L36 108 10 80Z
    final robePath = Path()
      ..moveTo(70 * sx, 20 * sy)
      ..lineTo(100 * sx, 40 * sy)
      ..lineTo(130 * sx, 20 * sy)
      ..lineTo(190 * sx, 80 * sy)
      ..lineTo(164 * sx, 108 * sy)
      ..lineTo(146 * sx, 92 * sy)
      ..lineTo(146 * sx, 184 * sy)
      ..lineTo(54 * sx, 184 * sy)
      ..lineTo(54 * sx, 92 * sy)
      ..lineTo(36 * sx, 108 * sy)
      ..lineTo(10 * sx, 80 * sy)
      ..close();

    canvas.drawPath(robePath, lavenderSilk);
    canvas.drawPath(robePath, robeOutline);

    // Collar seam
    canvas.drawLine(Offset(100 * sx, 40 * sy), Offset(100 * sx, 184 * sy), robeOutline);

    // Gold imperial waistband sash: M54 120H146
    final sashPaint = Paint()
      ..color = OriginColors.gold
      ..strokeWidth = 8 * sx;
    canvas.drawLine(Offset(54 * sx, 120 * sy), Offset(146 * sx, 120 * sy), sashPaint);

    // Imperial medallions (dragon roundels)
    final roundelPaint = Paint()
      ..color = OriginColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * sx;

    canvas.drawCircle(Offset(76 * sx, 150 * sy), 9 * sx, roundelPaint);
    canvas.drawCircle(Offset(124 * sx, 150 * sy), 9 * sx, roundelPaint);
    canvas.drawCircle(Offset(100 * sx, 70 * sy), 10 * sx, roundelPaint);
  }

  void _paintBox(Canvas canvas, Size size, double sx, double sy) {
    // Inlaid casket
    final darkWood = Paint()..color = const Color(0xFF3A2B1C);
    final lidWood = Paint()..color = const Color(0xFF4B3724);
    final goldLine = Paint()
      ..color = OriginColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * sx;

    // Body: rect M30 90H170V160H30Z
    final boxRect = Rect.fromLTWH(30 * sx, 90 * sy, 140 * sx, 70 * sy);
    canvas.drawRect(boxRect, darkWood);
    canvas.drawRect(boxRect, goldLine);

    // Dome lid: M30 90C34 60 166 60 170 90Z
    final lidPath = Path()
      ..moveTo(30 * sx, 90 * sy)
      ..cubicTo(34 * sx, 60 * sy, 166 * sx, 60 * sy, 170 * sx, 90 * sy)
      ..close();
    canvas.drawPath(lidPath, lidWood);
    canvas.drawPath(lidPath, goldLine);

    // Gold inlays (marquetry)
    final goldInlay = Paint()
      ..color = OriginColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * sx;

    canvas.drawLine(Offset(44 * sx, 110 * sy), Offset(156 * sx, 110 * sy), goldInlay);
    canvas.drawLine(Offset(44 * sx, 140 * sy), Offset(156 * sx, 140 * sy), goldInlay);
    canvas.drawCircle(Offset(100 * sx, 125 * sy), 12 * sx, goldInlay);

    // Clasp
    final claspRect = Rect.fromLTWH(92 * sx, 86 * sy, 16 * sx, 10 * sy);
    canvas.drawRect(claspRect, Paint()..color = OriginColors.gold);
    canvas.drawRect(claspRect, goldLine);
  }

  void _paintChair(Canvas canvas, Size size, double sx, double sy) {
    final goldWood = Paint()..color = OriginColors.gold;
    final cushion = Paint()..color = const Color(0xFFF1E2C6);
    final darkBorder = Paint()
      ..color = OriginColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * sx;

    // Backrest cushion: 48 30 to 152 92
    final backRect = Rect.fromLTWH(48 * sx, 30 * sy, 104 * sx, 62 * sy);
    canvas.drawRect(backRect, cushion);
    canvas.drawRect(backRect, darkBorder);

    // Seat: 36 92 to 164 118
    final seatRect = Rect.fromLTWH(36 * sx, 92 * sy, 128 * sx, 26 * sy);
    canvas.drawRect(seatRect, goldWood);
    canvas.drawRect(seatRect, darkBorder);

    // Legs
    final legPaint = Paint()
      ..color = OriginColors.goldDark
      ..strokeWidth = 6 * sx
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(44 * sx, 118 * sy), Offset(44 * sx, 176 * sy), legPaint);
    canvas.drawLine(Offset(156 * sx, 118 * sy), Offset(156 * sx, 176 * sy), legPaint);
    canvas.drawLine(Offset(70 * sx, 118 * sy), Offset(70 * sx, 160 * sy), legPaint);
    canvas.drawLine(Offset(130 * sx, 118 * sy), Offset(130 * sx, 160 * sy), legPaint);
  }

  void _paintEarrings(Canvas canvas, Size size, double sx, double sy) {
    final goldPaint = Paint()..color = OriginColors.gold;
    final sapphire = Paint()..color = const Color(0xFF2F5AA8);
    final darkBorder = Paint()
      ..color = const Color(0xFF8A642F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * sx;

    // Left earring stud: cx 70, cy 40, r 10
    canvas.drawCircle(Offset(70 * sx, 40 * sy), 10 * sx, goldPaint);
    canvas.drawCircle(Offset(70 * sx, 40 * sy), 10 * sx, darkBorder);
    canvas.drawLine(Offset(70 * sx, 50 * sy), Offset(70 * sx, 80 * sy), darkBorder);

    // Left sapphire drop: 70 80, 52 110, 70 150, 88 110
    final dropLeft = Path()
      ..moveTo(70 * sx, 80 * sy)
      ..lineTo(52 * sx, 110 * sy)
      ..lineTo(70 * sx, 150 * sy)
      ..lineTo(88 * sx, 110 * sy)
      ..close();
    canvas.drawPath(dropLeft, sapphire);
    canvas.drawPath(dropLeft, darkBorder);

    // Right earring stud: cx 130, cy 40, r 10
    canvas.drawCircle(Offset(130 * sx, 40 * sy), 10 * sx, goldPaint);
    canvas.drawCircle(Offset(130 * sx, 40 * sy), 10 * sx, darkBorder);
    canvas.drawLine(Offset(130 * sx, 50 * sy), Offset(130 * sx, 80 * sy), darkBorder);

    // Right sapphire drop: 130 80, 112 110, 130 150, 148 110
    final dropRight = Path()
      ..moveTo(130 * sx, 80 * sy)
      ..lineTo(112 * sx, 110 * sy)
      ..lineTo(130 * sx, 150 * sy)
      ..lineTo(148 * sx, 110 * sy)
      ..close();
    canvas.drawPath(dropRight, sapphire);
    canvas.drawPath(dropRight, darkBorder);
  }

  void _paintLotus(Canvas canvas, Size size, double sx, double sy) {
    final lotusPath = Path();
    // Center petal
    lotusPath.moveTo(50 * 2 * sx, 18 * 2 * sy);
    lotusPath.cubicTo(40 * 2 * sx, 34 * 2 * sy, 40 * 2 * sx, 52 * 2 * sy, 50 * 2 * sx, 66 * 2 * sy);
    lotusPath.cubicTo(60 * 2 * sx, 52 * 2 * sy, 60 * 2 * sx, 34 * 2 * sy, 50 * 2 * sx, 18 * 2 * sy);
    lotusPath.close();

    // Inner petals
    lotusPath.moveTo(50 * 2 * sx, 66 * 2 * sy);
    lotusPath.cubicTo(32 * 2 * sx, 62 * 2 * sy, 20 * 2 * sx, 48 * 2 * sy, 18 * 2 * sx, 30 * 2 * sy);
    lotusPath.cubicTo(34 * 2 * sx, 34 * 2 * sy, 46 * 2 * sx, 48 * 2 * sy, 50 * 2 * sx, 66 * 2 * sy);
    lotusPath.close();

    lotusPath.moveTo(50 * 2 * sx, 66 * 2 * sy);
    lotusPath.cubicTo(68 * 2 * sx, 62 * 2 * sy, 80 * 2 * sx, 48 * 2 * sy, 82 * 2 * sx, 30 * 2 * sy);
    lotusPath.cubicTo(66 * 2 * sx, 34 * 2 * sy, 54 * 2 * sx, 48 * 2 * sy, 50 * 2 * sx, 66 * 2 * sy);
    lotusPath.close();

    // Base
    lotusPath.moveTo(30 * 2 * sx, 80 * 2 * sy);
    lotusPath.lineTo(70 * 2 * sx, 80 * 2 * sy);

    final paint = Paint()
      ..color = OriginColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * sx
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(lotusPath, paint);
  }

  @override
  bool shouldRepaint(_ArtefactPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.angle != angle;
}
