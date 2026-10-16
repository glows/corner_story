import 'package:flutter/material.dart';

import '../services/corner_auth_service.dart';
import '../l10n/corner_l10n.dart';
import '../theme/corner_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.onAuthenticated, this.onBack});
  final VoidCallback onAuthenticated;
  final VoidCallback? onBack;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (_codeSent && !RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      setState(() => _error = 'Enter the six-digit code from your email.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_codeSent) {
        await CornerAuthService.instance.verifyEmailCode(email, _code.text);
        if (mounted) widget.onAuthenticated();
      } else {
        await CornerAuthService.instance.requestEmailCode(email);
        if (mounted) setState(() => _codeSent = true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _usePasskey() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await CornerAuthService.instance.signInWithPasskey();
      if (mounted) widget.onAuthenticated();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CornerColors.surface,
      appBar: AppBar(
        backgroundColor: CornerColors.surface,
        centerTitle: true,
        leading: IconButton(
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: cornerCopy(context, 'Back'),
        ),
        title: const CornerText(
          'CORNER ACCESS',
          style: CornerTypography.labelCaps,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
          children: [
            const CornerText(
              '●  AUTHENTICATION PROTOCOL',
              style: CornerTypography.labelCaps,
            ),
            const SizedBox(height: 14),
            CornerText(
              _codeSent
                  ? 'Check your private dispatch.'
                  : 'Return to your quiet spaces.',
              style: CornerTypography.displayMobile,
            ),
            const SizedBox(height: 14),
            CornerText(
              _codeSent
                  ? 'Check ${_email.text.trim()} for a one-time code. It expires in five minutes.'
                  : 'Sign in password-free with a single-use code sent to your email.',
              style: CornerTypography.bodyLg,
            ),
            const SizedBox(height: 28),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/img_12.jpg',
                height: 155,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CornerColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CornerText(
                    'PERSONAL EDITORIAL DISPATCH',
                    style: CornerTypography.labelCaps,
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    controller: _email,
                    enabled: !_busy && !_codeSent,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      hintText: CornerL10n.translate(
                        context,
                        'you@example.com',
                      ),
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _code,
                      enabled: !_busy,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: CornerL10n.translate(
                          context,
                          'Six-digit access code',
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    SelectableText(
                      CornerL10n.translate(context, _error!),
                      style: CornerTypography.bodySm.copyWith(
                        color: CornerColors.terracotta,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: CornerColors.primary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : CornerText(
                            _codeSent
                                ? 'Enter Corner  →'
                                : 'Send Access Code  →',
                          ),
                  ),
                  if (_codeSent)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _codeSent = false;
                              _code.clear();
                            }),
                      child: const CornerText('Use a different email'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _busy ? null : _usePasskey,
              icon: const Icon(Icons.fingerprint),
              label: const CornerText('Authenticate with Passkey / Face ID'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
            const SizedBox(height: 8),
            const CornerText(
              'Use a passkey you previously added to Corner. Your device may ask for a fingerprint, face scan or PIN.',
              style: CornerTypography.bodySm,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: CornerColors.surfaceContainer,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: CornerText(
                      'Your access code is single-use. Your session stays private on this device.',
                      style: CornerTypography.bodySm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
