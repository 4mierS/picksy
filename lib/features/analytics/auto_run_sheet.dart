import 'package:flutter/material.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/l10n/l10n.dart';

/// Shows a bottom sheet that runs a generator N times and displays distribution.
Future<void> showAutoRunSheet(
  BuildContext context, {
  required String Function() generator,
  required String generatorName,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _AutoRunSheet(
      generator: generator,
      generatorName: generatorName,
    ),
  );
}

class _AutoRunSheet extends StatefulWidget {
  final String Function() generator;
  final String generatorName;

  const _AutoRunSheet({
    required this.generator,
    required this.generatorName,
  });

  @override
  State<_AutoRunSheet> createState() => _AutoRunSheetState();
}

class _AutoRunSheetState extends State<_AutoRunSheet> {
  double _count = 100;
  bool _running = false;
  bool _done = false;
  Map<String, int> _distribution = {};
  int _processed = 0;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _done = false;
      _distribution = {};
      _processed = 0;
    });

    final total = _count.round();
    final Map<String, int> dist = {};
    const batchSize = 50;

    for (int i = 0; i < total; i += batchSize) {
      if (!mounted) return;
      final end = (i + batchSize).clamp(0, total);
      for (int j = i; j < end; j++) {
        final result = widget.generator();
        dist[result] = (dist[result] ?? 0) + 1;
      }
      setState(() => _processed = end);
      await Future.delayed(const Duration(milliseconds: 8));
    }

    if (!mounted) return;
    setState(() {
      _running = false;
      _done = true;
      _distribution = Map.fromEntries(
        dist.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = _count.round();
    final maxVal =
        _distribution.values.isNotEmpty ? _distribution.values.first : 1;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.analyticsAutoRun,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.proPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.generatorName,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Count selector
                Row(
                  children: [
                    Text(
                      l10n.analyticsAutoRunCount,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.proPurple,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _count,
                  min: 10,
                  max: 1000,
                  divisions: 99,
                  activeColor: AppColors.proPurple,
                  onChanged: _running
                      ? null
                      : (v) => setState(() => _count = v),
                ),

                const SizedBox(height: 12),

                // Progress bar when running
                if (_running) ...[
                  LinearProgressIndicator(
                    value: _processed / total,
                    color: AppColors.proPurple,
                    backgroundColor: AppColors.proPurple.withOpacity(0.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_processed / $total',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                ],

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.proPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _running ? null : _run,
                    child: Text(
                      _running
                          ? l10n.analyticsAutoRunRunning
                          : l10n.analyticsAutoRunStart,
                    ),
                  ),
                ),

                // Results
                if (_done && _distribution.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.analyticsAutoRunDistribution,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final entry in _distribution.entries.take(20)) ...[
                    _DistributionBar(
                      label: entry.key,
                      count: entry.value,
                      total: total,
                      maxVal: maxVal,
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (_distribution.length > 20)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${_distribution.length - 20} more…',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final int maxVal;

  const _DistributionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.maxVal,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    final barFrac = maxVal > 0 ? count / maxVal : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.proPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 18,
                    width: constraints.maxWidth * barFrac,
                    decoration: BoxDecoration(
                      color: AppColors.proPurple.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            '$count (${(pct * 100).toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
