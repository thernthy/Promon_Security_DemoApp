import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'transfer_success_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.onCompleted});

  /// Called after the user dismisses the success screen.
  final VoidCallback? onCompleted;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  static const _quickAmounts = [50, 100, 250, 500];

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _fromId;
  Contact? _recipient;
  bool _processing = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    _formKey.currentState?.reset();
    _amountCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _recipient = null;
      _processing = false;
    });
  }

  Future<void> _continue(Account from) async {
    FocusScope.of(context).unfocus();
    final recipient = _recipient;
    if (recipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountCtrl.text);
    final note = _noteCtrl.text.trim();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ConfirmSheet(
        from: from,
        to: recipient,
        amount: amount,
        note: note,
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final app = AppScope.of(context);
    final tx = app.transfer(
      fromAccountId: from.id,
      to: recipient,
      amount: amount,
      note: note,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransferSuccessScreen(
          transaction: tx,
          from: from,
          to: recipient,
          amount: amount,
          note: note,
        ),
      ),
    );
    if (!mounted) return;
    _reset();
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final from = app.accountById(_fromId ?? app.accounts.first.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _Label('From account'),
            Row(
              children: [
                for (var i = 0; i < app.accounts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _AccountOption(
                      account: app.accounts[i],
                      selected: app.accounts[i].id == from.id,
                      onTap: () =>
                          setState(() => _fromId = app.accounts[i].id),
                    ),
                  ),
                ],
              ],
            ),
            const _Label('Send to'),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: app.contacts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  final contact = app.contacts[i];
                  return _ContactAvatar(
                    contact: contact,
                    selected: contact.id == _recipient?.id,
                    onTap: () => setState(() => _recipient = contact),
                  );
                },
              ),
            ),
            if (_recipient != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.card,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _recipient!.color,
                      child: Text(_recipient!.initials,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_recipient!.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${_recipient!.bank} · ${_recipient!.maskedAccount}',
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppTheme.success),
                  ],
                ),
              ),
            ],
            const _Label('Amount'),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: AppTheme.input('Amount', prefixText: '\$ '),
              validator: (v) {
                final amount = double.tryParse(v ?? '');
                if (v == null || v.isEmpty) return 'Enter an amount';
                if (amount == null || amount <= 0) {
                  return 'Amount must be greater than 0';
                }
                if (amount > from.balance) return 'Insufficient funds';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Available: ${formatCurrency(from.balance)}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in _quickAmounts)
                  ActionChip(
                    label: Text('\$$value'),
                    backgroundColor: Colors.white,
                    onPressed: () => setState(
                        () => _amountCtrl.text = value.toStringAsFixed(2)),
                  ),
              ],
            ),
            const _Label('Note (optional)'),
            TextFormField(
              controller: _noteCtrl,
              maxLength: 50,
              decoration: AppTheme.input(
                'What is this for?',
                icon: Icons.edit_note_rounded,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _processing ? null : () => _continue(from),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _processing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Continue',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    );
  }
}

class _AccountOption extends StatelessWidget {
  const _AccountOption({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final Account account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.black12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              account.type == AccountType.checking
                  ? Icons.account_balance_wallet_outlined
                  : Icons.savings_outlined,
              color: selected ? Colors.white : AppTheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              account.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(account.balance),
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white70 : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.contact,
    required this.selected,
    required this.onTap,
  });

  final Contact contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppTheme.primary : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: contact.color,
                child: Text(
                  contact.initials,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              contact.name.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.from,
    required this.to,
    required this.amount,
    required this.note,
  });

  final Account from;
  final Contact to;
  final double amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Confirm Transfer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(amount),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            _SummaryRow('From', '${from.name} ${from.masked}'),
            _SummaryRow('To', to.name),
            _SummaryRow('Bank', '${to.bank} ${to.maskedAccount}'),
            if (note.isNotEmpty) _SummaryRow('Note', note),
            const _SummaryRow('Fee', '\$0.00'),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Confirm & Send',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child:
                Text(label, style: const TextStyle(color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
