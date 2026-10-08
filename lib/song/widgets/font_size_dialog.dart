import 'package:flutter/material.dart';

class FontSizeDialog extends StatelessWidget {
  final double currentSize;
  final ValueChanged<double> onSizeChanged;

  const FontSizeDialog({
    super.key,
    required this.currentSize,
    required this.onSizeChanged,
  });

  static void show(BuildContext context, {
    required double currentSize,
    required ValueChanged<double> onSizeChanged,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FontSizeDialog(
        currentSize: currentSize,
        onSizeChanged: onSizeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Қаріп өлшемі / Font size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${currentSize.round()} pt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: currentSize > 14
                        ? () {
                            final newSize = (currentSize - 2).clamp(14.0, 36.0);
                            onSizeChanged(newSize);
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.text_decrease),
                  ),
                  Expanded(
                    child: Slider(
                      value: currentSize.clamp(14.0, 36.0),
                      min: 14.0,
                      max: 36.0,
                      divisions: 11,
                      label: '${currentSize.round()} pt',
                      onChanged: (value) {
                        onSizeChanged(value);
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: currentSize < 36
                        ? () {
                            final newSize = (currentSize + 2).clamp(14.0, 36.0);
                            onSizeChanged(newSize);
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.text_increase),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Құдайға мадақ айтайық!',
                  style: TextStyle(
                    fontSize: currentSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
