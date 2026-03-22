part of 'student_home_view.dart';

class _StudentResultsView extends StatelessWidget {
  const _StudentResultsView({required this.summary});

  final _StudentResultsSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(22, 22, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Results',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View your peer assessment feedback',
                    style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: Column(
            children: [
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your average score across all criteria',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            summary.overallScore.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 46,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Out of 5.0',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.secondarySlate,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ResultsStat(
                                value: '${summary.assessmentCount}',
                                label: 'Assessments',
                              ),
                              const SizedBox(width: 30),
                              _ResultsStat(
                                value: '${summary.reviewCount}',
                                label: 'Reviews',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Criteria Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your scores by evaluation criteria',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: SizedBox(
                        width: 320,
                        height: 320,
                        child: _RadarChart(scores: summary.criteria),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Scores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Breakdown by criteria',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...summary.criteria.map(
                      (criterion) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _DetailedScoreRow(score: criterion),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your past peer assessments',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...summary.history.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AssessmentHistoryCard(item: item),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultsStat extends StatelessWidget {
  const _ResultsStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppTheme.secondarySlate),
        ),
      ],
    );
  }
}

class _DetailedScoreRow extends StatelessWidget {
  const _DetailedScoreRow({required this.score});

  final _StudentCriterionScore score;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final bar = Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: score.score / 5,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFD9D9D9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 42,
                child: Text(
                  score.score.toStringAsFixed(1),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                score.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [bar]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Text(
                score.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(child: bar),
          ],
        );
      },
    );
  }
}

class _AssessmentHistoryCard extends StatelessWidget {
  const _AssessmentHistoryCard({required this.item});

  final _StudentAssessmentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChart extends StatefulWidget {
  const _RadarChart({required this.scores});

  final List<_StudentCriterionScore> scores;

  @override
  State<_RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<_RadarChart> {
  int? _activeIndex;

  void _updateActiveIndex(Offset localPosition, Size size) {
    final index = _RadarChartPainter.hitTestIndex(
      localPosition: localPosition,
      size: size,
      scores: widget.scores,
    );
    setState(() => _activeIndex = index);
  }

  void _clearActiveIndex() {
    if (_activeIndex != null) {
      setState(() => _activeIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final tooltipPosition = _activeIndex == null
            ? null
            : _RadarChartPainter.tooltipPositionForIndex(
                index: _activeIndex!,
                size: size,
                scores: widget.scores,
              );

        return MouseRegion(
          onHover: (event) => _updateActiveIndex(event.localPosition, size),
          onExit: (_) => _clearActiveIndex(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                _updateActiveIndex(details.localPosition, size),
            onPanDown: (details) =>
                _updateActiveIndex(details.localPosition, size),
            onPanUpdate: (details) =>
                _updateActiveIndex(details.localPosition, size),
            onTap: () {},
            child: Stack(
              children: [
                CustomPaint(
                  painter: _RadarChartPainter(
                    scores: widget.scores,
                    activeIndex: _activeIndex,
                  ),
                  child: const SizedBox.expand(),
                ),
                if (_activeIndex != null && tooltipPosition != null)
                  Positioned(
                    left: tooltipPosition.dx,
                    top: tooltipPosition.dy,
                    child: IgnorePointer(
                      child: Container(
                        width: 94,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD3D3D3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.scores[_activeIndex!].label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Score : ${widget.scores[_activeIndex!].score.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({required this.scores, this.activeIndex});

  final List<_StudentCriterionScore> scores;
  final int? activeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    final axisPaint = Paint()
      ..color = const Color(0xFF6F796D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var ring = 1; ring <= 2; ring++) {
      final ringPath = Path();
      for (var i = 0; i < scores.length; i++) {
        final point = pointForIndex(
          index: i,
          count: scores.length,
          center: center,
          radius: radius * (ring / 2),
        );
        if (i == 0) {
          ringPath.moveTo(point.dx, point.dy);
        } else {
          ringPath.lineTo(point.dx, point.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, axisPaint);
    }

    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius,
      );
      canvas.drawLine(center, point, axisPaint);
    }

    final scorePath = Path();
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / 5),
      );
      if (i == 0) {
        scorePath.moveTo(point.dx, point.dy);
      } else {
        scorePath.lineTo(point.dx, point.dy);
      }
    }
    scorePath.close();
    canvas.drawPath(scorePath, fillPaint);
    canvas.drawPath(scorePath, outlinePaint);

    final pointPaint = Paint()..color = AppTheme.primaryGreen;
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / 5),
      );
      canvas.drawCircle(point, activeIndex == i ? 4.5 : 3.5, pointPaint);
    }

    final labelStyle = const TextStyle(
      fontSize: 14,
      color: AppTheme.secondarySlate,
    );
    final tickStyle = const TextStyle(
      fontSize: 12,
      color: AppTheme.secondarySlate,
    );

    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius + 18,
      );
      final painter = TextPainter(
        text: TextSpan(text: scores[i].label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(point.dx - painter.width / 2, point.dy - painter.height / 2),
      );
    }

    final zeroPainter = TextPainter(
      text: TextSpan(text: '0', style: tickStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    zeroPainter.paint(canvas, Offset(center.dx - 3, center.dy - 12));

    final twoPainter = TextPainter(
      text: TextSpan(text: '2', style: tickStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    twoPainter.paint(
      canvas,
      Offset(center.dx - 3, center.dy - radius / 2 - 10),
    );

    final fivePainter = TextPainter(
      text: TextSpan(text: '5', style: tickStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    fivePainter.paint(canvas, Offset(center.dx - 3, center.dy - radius - 10));
  }

  static int? hitTestIndex({
    required Offset localPosition,
    required Size size,
    required List<_StudentCriterionScore> scores,
  }) {
    if (scores.isEmpty) {
      return null;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / 5),
      );
      if ((localPosition - point).distance <= 28) {
        return i;
      }
    }

    return null;
  }

  static Offset tooltipPositionForIndex({
    required int index,
    required Size size,
    required List<_StudentCriterionScore> scores,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    final point = pointForIndex(
      index: index,
      count: scores.length,
      center: center,
      radius: radius * (scores[index].score / 5),
    );

    final left = max(10.0, min(size.width - 104, point.dx + 10));
    final top = max(10.0, min(size.height - 74, point.dy - 18));
    return Offset(left, top);
  }

  static Offset pointForIndex({
    required int index,
    required int count,
    required Offset center,
    required double radius,
  }) {
    final angle = (-90 + (360 / count) * index) * 3.141592653589793 / 180;
    return Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.activeIndex != activeIndex;
  }
}
