import 'package:flutter/material.dart';

import '../services/corner_auth_service.dart';
import '../services/corner_passkeys.dart';
import '../theme/corner_theme.dart';

class PasskeysScreen extends StatefulWidget {
  const PasskeysScreen({super.key, this.service});
  final CornerPasskeys? service;
  @override
  State<PasskeysScreen> createState() => _PasskeysScreenState();
}

class _PasskeysScreenState extends State<PasskeysScreen> {
  late final CornerPasskeys _service =
      widget.service ?? CornerAuthService.instance.passkeys;
  List<Map<String, dynamic>> _keys = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final keys = await _service.list();
      if (mounted) setState(() => _keys = keys);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _name({String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CornerText('Name your passkey'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 64,
          decoration: InputDecoration(
            hintText: cornerCopy(context, 'My phone or laptop'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CornerText('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const CornerText('Continue'),
          ),
        ],
      ),
    );
    // The route may still be animating while it owns the controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    return name;
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
      if (mounted) await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final name = await _name();
    if (name == null || !mounted) return;
    await _run(() => _service.register(name));
  }

  Future<void> _rename(Map<String, dynamic> key) async {
    final name = await _name(initial: key['name']?.toString() ?? '');
    if (name == null || !mounted) return;
    await _run(() => _service.rename(key['id'].toString(), name));
  }

  Future<void> _delete(Map<String, dynamic> key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CornerText('Remove this passkey?'),
        content: const CornerText(
          'It will no longer sign in to Corner. You can still use email. Remove its saved copy from your credential manager separately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const CornerText('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const CornerText('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(() => _service.delete(key['id'].toString()));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: CornerColors.surface,
    appBar: AppBar(
      title: const CornerText('PASSKEYS', style: CornerTypography.labelCaps),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CornerText(
          'Your private access.',
          style: CornerTypography.displayMobile,
        ),
        const SizedBox(height: 16),
        const CornerText(
          'Create a passkey after signing in with email. Next time, your device can verify you with a fingerprint, face scan or PIN. Corner only stores the public key.',
          style: CornerTypography.bodyLg,
        ),
        const SizedBox(height: 24),
        if (_error != null) ...[
          CornerText(
            _error!,
            style: CornerTypography.bodySm.copyWith(
              color: CornerColors.terracotta,
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _load,
            child: const CornerText('Retry'),
          ),
        ],
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_keys.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CornerText(
              'No passkeys added yet.',
              style: CornerTypography.bodyMd,
            ),
          ),
        for (final key in _keys)
          Card(
            child: ListTile(
              leading: const Icon(Icons.key_outlined),
              title: CornerText(
                key['name']?.toString().isNotEmpty == true
                    ? key['name'].toString()
                    : 'Passkey',
              ),
              subtitle: CornerText(
                key['backedUp'] == true || key['backedUp'] == 1
                    ? 'Synced by your credential provider'
                    : 'Saved by your device',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: cornerCopy(context, 'Rename passkey'),
                    onPressed: _busy ? null : () => _rename(key),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: cornerCopy(context, 'Remove passkey'),
                    onPressed: _busy ? null : () => _delete(key),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy || _loading ? null : _add,
          icon: const Icon(Icons.fingerprint),
          label: CornerText(
            _busy ? 'Waiting for your device…' : 'Add a passkey',
          ),
        ),
        if (_service.unavailableReason != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SelectableText(
              _service.unavailableReason!,
              style: CornerTypography.bodySm,
            ),
          ),
      ],
    ),
  );
}
