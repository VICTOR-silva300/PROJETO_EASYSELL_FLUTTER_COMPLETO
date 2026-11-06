import 'package:flutter/material.dart';
import 'tema.dart';

class FundoLateral extends StatelessWidget {
  final Widget child;

  const FundoLateral({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: CustomPaint(painter: _FundoPainter(cores))),
        child,
      ],
    );
  }
}

class _FundoPainter extends CustomPainter {
  final AppCores cores;

  const _FundoPainter(this.cores);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final area = Offset.zero & size;
    final fundo = Paint()
      ..shader = cores.gradFundo.createShader(area);
    canvas.drawRect(area, fundo);

    final intensidadeNeblina = cores.ehEscuro ? 0.13 : 0.17;

    void desenharNeblina(Offset centro, double raio, double intensidade) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            cores.azul.withValues(alpha: intensidadeNeblina * intensidade),
            cores.azul.withValues(alpha: intensidadeNeblina * intensidade * 0.32),
            cores.azul.withValues(alpha: 0),
          ],
          stops: const [0, 0.52, 1],
        ).createShader(Rect.fromCircle(center: centro, radius: raio));
      canvas.drawCircle(centro, raio, paint);
    }

    desenharNeblina(Offset(-size.width * 0.05, size.height * 0.08), size.width * 0.43, 1);
    desenharNeblina(Offset(size.width * 1.04, size.height * 0.94), size.width * 0.39, 0.78);

    final opacidadeLinha = cores.ehEscuro ? 0.42 : 0.30;
    final linha = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round
      ..color = cores.azul.withValues(alpha: opacidadeLinha);

    final linhaSuave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = cores.azul.withValues(alpha: opacidadeLinha * 0.48);

    final superior = Path()
      ..moveTo(-size.width * 0.04, size.height * 0.19)
      ..cubicTo(
        size.width * 0.10,
        size.height * 0.13,
        size.width * 0.12,
        size.height * 0.035,
        size.width * 0.25,
        -size.height * 0.025,
      );
    canvas.drawPath(superior, linha);
    final superiorInterna = Path()
      ..moveTo(-size.width * 0.025, size.height * 0.235)
      ..cubicTo(
        size.width * 0.105,
        size.height * 0.17,
        size.width * 0.145,
        size.height * 0.065,
        size.width * 0.285,
        -size.height * 0.015,
      );
    canvas.drawPath(superiorInterna, linhaSuave);

    final inferior = Path()
      ..moveTo(size.width * 0.73, size.height * 1.035)
      ..cubicTo(
        size.width * 0.80,
        size.height * 0.88,
        size.width * 0.86,
        size.height * 0.88,
        size.width * 1.035,
        size.height * 0.73,
      );
    canvas.drawPath(inferior, linha);
    final inferiorInterna = Path()
      ..moveTo(size.width * 0.69, size.height * 1.02)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.85,
        size.width * 0.88,
        size.height * 0.84,
        size.width * 1.025,
        size.height * 0.68,
      );
    canvas.drawPath(inferiorInterna, linhaSuave);
  }

  @override
  bool shouldRepaint(covariant _FundoPainter oldDelegate) => oldDelegate.cores != cores;
}
