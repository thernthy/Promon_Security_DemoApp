import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = AppScope.of(context).transactions;
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: AppTheme.card,
            child: Column(
              children: [
                for (final tx in transactions) TransactionTile(transaction: tx),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
