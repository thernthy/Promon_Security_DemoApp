import 'package:bank_demo_app/main.dart';
import 'package:bank_demo_app/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo user can log in and reach home', (tester) async {
    await tester.pumpWidget(BankDemoApp(state: AppState()));

    await tester.ensureVisible(find.text('Use demo account'));
    await tester.tap(find.text('Use demo account'));
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Alex Morgan'), findsWidgets);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });

  testWidgets('wrong password shows an error', (tester) async {
    await tester.pumpWidget(BankDemoApp(state: AppState()));

    await tester.enterText(find.byType(TextFormField).at(0), 'demo');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Invalid username or password'), findsOneWidget);
  });

  test('transfer deducts balance and records a transaction', () {
    final app = AppState();
    final account = app.accounts.first;
    final before = account.balance;

    app.transfer(fromAccountId: account.id, to: app.contacts.first, amount: 100);

    expect(account.balance, closeTo(before - 100, 0.001));
    expect(app.transactions.first.amount, -100);
  });
}
