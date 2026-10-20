import 'package:flutter/widgets.dart';

import '../data/demo_data.dart';
import '../models/models.dart';

/// In-memory app state backed by [DemoData]. Changes last until logout.
class AppState extends ChangeNotifier {
  BankUser? currentUser;
  List<Account> accounts = DemoData.accounts();
  List<BankTransaction> transactions = DemoData.transactions();
  final List<Contact> contacts = DemoData.contacts;

  double get totalBalance => accounts.fold(0, (sum, a) => sum + a.balance);

  bool login(String username, String password) {
    final user = DemoData.user;
    if (username.toLowerCase() == user.username && password == user.password) {
      currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
    accounts = DemoData.accounts();
    transactions = DemoData.transactions();
    notifyListeners();
  }

  Account accountById(String id) => accounts.firstWhere((a) => a.id == id);

  BankTransaction transfer({
    required String fromAccountId,
    required Contact to,
    required double amount,
    String note = '',
  }) {
    final account = accountById(fromAccountId);
    if (amount <= 0 || amount > account.balance) {
      throw StateError('Insufficient funds');
    }
    account.balance =
        double.parse((account.balance - amount).toStringAsFixed(2));

    final tx = BankTransaction(
      id: 'TX${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer to ${to.name}',
      subtitle: note.isEmpty ? '${to.bank} ${to.maskedAccount}' : note,
      amount: -amount,
      date: DateTime.now(),
      category: TxCategory.transfer,
    );
    transactions.insert(0, tx);
    notifyListeners();
    return tx;
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!.notifier!;
  }
}
