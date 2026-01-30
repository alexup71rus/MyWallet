import 'package:flutter/material.dart';
import 'package:mywallet/l10n/app_localizations.dart';

class DevToolsSection extends StatefulWidget {
  final int count;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onGenerate;
  final VoidCallback onRemove;

  const DevToolsSection({
    super.key,
    required this.count,
    required this.onCountChanged,
    required this.onGenerate,
    required this.onRemove,
  });

  @override
  State<DevToolsSection> createState() => _DevToolsSectionState();
}

class _DevToolsSectionState extends State<DevToolsSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.count.toString());
  }

  @override
  void didUpdateWidget(DevToolsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.text = widget.count.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.settingsDevToolsSection,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.tune),
          title: Text(l10n.settingsDemoCardsCountLabel),
          trailing: SizedBox(
            width: 72,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              onSubmitted: (value) {
                final parsed = int.tryParse(value) ?? widget.count;
                widget.onCountChanged(parsed);
              },
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: Text(l10n.settingsDemoCardsGenerate),
          onTap: widget.onGenerate,
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text(l10n.settingsDemoCardsRemove),
          onTap: widget.onRemove,
        ),
      ],
    );
  }
}
