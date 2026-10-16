import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../services/corner_auth_service.dart';
import '../theme/corner_theme.dart';
import 'passkeys_screen.dart';

class PrivacyCirclesScreen extends StatefulWidget {
  const PrivacyCirclesScreen({super.key, this.onSignOut});
  final VoidCallback? onSignOut;
  @override
  State<PrivacyCirclesScreen> createState() => _PrivacyCirclesScreenState();
}

class _PrivacyCirclesScreenState extends State<PrivacyCirclesScreen> {
  String _scope = 'inner';
  bool _ghostSaves = true;
  bool _hideVisits = true;
  bool _fuzzyGeo = false;
  bool _loading = true;
  bool _saving = false;
  List<Map<String, dynamic>> _circle = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Uri _uri(String path) =>
      Uri.parse('${CornerAuthService.instance.baseUrl}/api/v1/privacy$path');
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    ...CornerAuthService.instance.authHeaders,
  };

  Future<Map<String, dynamic>> _read(http.Response response) async {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'Request failed');
    }
    return data;
  }

  Future<void> _load() async {
    try {
      final data = await _read(await http.get(_uri(''), headers: _headers));
      final settings = data['settings'] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _scope = settings['map_scope'] as String;
        _ghostSaves =
            settings['ghost_saves'] == 1 || settings['ghost_saves'] == true;
        _hideVisits =
            settings['hide_visits'] == 1 || settings['hide_visits'] == true;
        _fuzzyGeo = settings['fuzzy_geo'] == 1 || settings['fuzzy_geo'] == true;
        _circle = (data['circle'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        _notice(error.toString());
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _read(
        await http.put(
          _uri(''),
          headers: _headers,
          body: jsonEncode({
            'map_scope': _scope,
            'ghost_saves': _ghostSaves,
            'hide_visits': _hideVisits,
            'fuzzy_geo': _fuzzyGeo,
          }),
        ),
      );
      _notice('Privacy settings saved');
    } catch (error) {
      _notice(error.toString());
      await _load();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: CornerText(message)));
  }

  Future<void> _removeFriend(Map<String, dynamic> friend) async {
    final name = friend['display_name']?.toString() ?? 'this person';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CornerText('Remove from your circle?'),
        content: CornerText('$name will no longer see your shared footprint.'),
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
    if (confirmed != true) return;
    try {
      await _read(
        await http.delete(_uri('/circle/${friend['id']}'), headers: _headers),
      );
      await _load();
      _notice('Removed from your circle');
    } catch (error) {
      _notice(error.toString());
    }
  }

  Future<void> _export() async {
    try {
      final response = await http.get(_uri('/export'), headers: _headers);
      await _read(response);
      await Clipboard.setData(ClipboardData(text: response.body));
      _notice('Your data export was copied as JSON');
    } catch (error) {
      _notice(error.toString());
    }
  }

  Future<void> _deleteAccount() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CornerText('Delete your Corner?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CornerText(
              'This permanently deletes your account, saved places, notes, and circle. Type DELETE MY CORNER to continue.',
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'DELETE MY CORNER'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const CornerText('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text == 'DELETE MY CORNER'),
            child: const CornerText('Delete account'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (confirmed != true) return;
    try {
      await _read(
        await http.delete(
          _uri('/account'),
          headers: _headers,
          body: jsonEncode({'confirm': 'DELETE MY CORNER'}),
        ),
      );
      await CornerAuthService.instance.signOutLocal();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSignOut?.call();
    } catch (error) {
      _notice(error.toString());
    }
  }

  Future<void> _signOut() async {
    await CornerAuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onSignOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CornerColors.surface,
      appBar: AppBar(
        backgroundColor: CornerColors.surface,
        title: const CornerText(
          'Privacy And Circles',
          style: CornerTypography.headlineSm,
        ),
        actions: [
          IconButton(
            onPressed: _signOut,
            tooltip: cornerCopy(context, 'Sign out'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fingerprint),
                  title: const CornerText('Passkeys & device verification'),
                  subtitle: const CornerText(
                    'Add, rename or remove your passkeys',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PasskeysScreen()),
                  ),
                ),
                const CornerText(
                  'DISPATCH SETTINGS · TRUST & PERMISSIONS',
                  style: CornerTypography.labelCaps,
                ),
                const SizedBox(height: 9),
                CornerText(
                  'Curate your circle.\nProtect your quiet spaces.',
                  style: CornerTypography.headlineMd.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                const CornerText(
                  'Choose who can see your real-world footprint and manage the people in your circle.',
                  style: CornerTypography.bodyMd,
                ),
                const SizedBox(height: 23),
                _sectionTitle('Map Footprint Scope', 'GEO-BROADCAST'),
                _scopeCard(
                  'inner',
                  Icons.group_outlined,
                  'IRL Inner Circle Only',
                  'Only people in your approved circle can see your shared pins.',
                ),
                _scopeCard(
                  'radar',
                  Icons.radar,
                  'Extended Taste Radar',
                  'Your shared pins can appear to the broader taste network.',
                ),
                _scopeCard(
                  'ghost',
                  Icons.visibility_off_outlined,
                  'Incognito Ghost Mode',
                  'Your shared pins stay hidden from other people.',
                ),
                const SizedBox(height: 17),
                _sectionTitle('Secret Corners & Archives', 'VAULT RULES'),
                _toggle(
                  'Ghost Save Mode',
                  'Hide saved-spot activity from feeds.',
                  _ghostSaves,
                  (value) => setState(() => _ghostSaves = value),
                ),
                _toggle(
                  'Hide Bar & Cellar Visits',
                  'Keep visit history private.',
                  _hideVisits,
                  (value) => setState(() => _hideVisits = value),
                ),
                _toggle(
                  'Fuzz Geo-Coordinates',
                  'Show a neighborhood instead of an exact location.',
                  _fuzzyGeo,
                  (value) => setState(() => _fuzzyGeo = value),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: CornerColors.primary,
                    minimumSize: const Size.fromHeight(47),
                  ),
                  child: CornerText(
                    _saving ? 'Saving…' : 'Save Privacy Settings',
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Active IRL Circle', '${_circle.length} MEMBERS'),
                if (_circle.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: CornerText(
                      'No people in your circle yet.',
                      style: CornerTypography.bodySm,
                    ),
                  ),
                for (final friend in _circle)
                  Card(
                    color: CornerColors.surfaceContainerLowest,
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: CornerText(
                        friend['display_name']?.toString() ?? 'Corner member',
                      ),
                      subtitle: CornerText(
                        friend['taste_badge']?.toString() ?? 'Friend IRL',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_horiz),
                        tooltip: cornerCopy(context, 'Remove from circle'),
                        onPressed: () => _removeFriend(friend),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _sectionTitle('Data Autonomy & Export', 'PORTABILITY'),
                _actionCard(
                  'Export Curated Atlas',
                  'Copy your account data as JSON.',
                  'Export',
                  _export,
                ),
                _actionCard(
                  'Delete Footprint & Account',
                  'Permanently remove your account and its data.',
                  'Delete',
                  _deleteAccount,
                  destructive: true,
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      children: [
        Expanded(
          child: CornerText(title, style: CornerTypography.titleEditorial),
        ),
        CornerText(label, style: CornerTypography.labelCaps),
      ],
    ),
  );

  Widget _scopeCard(String value, IconData icon, String title, String detail) =>
      Card(
        color: _scope == value
            ? CornerColors.surfaceContainerLowest
            : CornerColors.surfaceContainerLow,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => setState(() => _scope = value),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CornerText(title, style: CornerTypography.labelMd),
                      CornerText(detail, style: CornerTypography.bodySm),
                    ],
                  ),
                ),
                Icon(
                  _scope == value
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _toggle(
    String title,
    String detail,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Card(
    color: CornerColors.surfaceContainerLowest,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: CornerColors.primary,
      title: CornerText(title, style: CornerTypography.labelMd),
      subtitle: CornerText(detail, style: CornerTypography.bodySm),
    ),
  );

  Widget _actionCard(
    String title,
    String detail,
    String action,
    VoidCallback onPressed, {
    bool destructive = false,
  }) => Card(
    color: CornerColors.surfaceContainerLowest,
    elevation: 0,
    child: ListTile(
      title: CornerText(title, style: CornerTypography.labelMd),
      subtitle: CornerText(detail, style: CornerTypography.bodySm),
      trailing: TextButton(
        onPressed: onPressed,
        child: CornerText(
          action,
          style: TextStyle(
            color: destructive ? CornerColors.terracotta : CornerColors.primary,
          ),
        ),
      ),
    ),
  );
}
