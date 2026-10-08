import 'package:flutter/material.dart';

class JumpToSongDialog extends StatefulWidget {
  final int maxSongNumber;
  final ValueChanged<int> onSongSelected;

  const JumpToSongDialog({
    super.key,
    required this.maxSongNumber,
    required this.onSongSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required int maxSongNumber,
    required ValueChanged<int> onSongSelected,
  }) {
    return showDialog(
      context: context,
      builder: (context) => JumpToSongDialog(
        maxSongNumber: maxSongNumber,
        onSongSelected: onSongSelected,
      ),
    );
  }

  @override
  State<JumpToSongDialog> createState() => _JumpToSongDialogState();
}

class _JumpToSongDialogState extends State<JumpToSongDialog> {
  final _controller = TextEditingController();
  String? _error;

  void _submit() {
    final text = _controller.text.trim();
    final num = int.tryParse(text);
    if (num == null || num < 1 || num > widget.maxSongNumber) {
      setState(() {
        _error = '1 - ${widget.maxSongNumber} аралығындағы нөмір жазыңыз';
      });
      return;
    }
    Navigator.of(context).pop();
    widget.onSongSelected(num);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ән нөміріне өту'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Ән нөмірі (1 - ${widget.maxSongNumber})',
              errorText: _error,
              prefixIcon: const Icon(Icons.tag),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Бас тарту'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Өту'),
        ),
      ],
    );
  }
}
