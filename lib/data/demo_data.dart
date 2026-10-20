import 'package:flutter/material.dart';

import '../models/models.dart';

/// All static demo data used by the app. Nothing here talks to a server.
class DemoData {
  static final user = BankUser(
    username: 'demo',
    password: 'demo123',
    fullName: 'Alex Morgan',
    email: 'alex.morgan@demobank.com',
    phone: '+1 (555) 214-7890',
    address: '742 Evergreen Terrace, Springfield, IL',
    customerId: 'DB-00482916',
    memberSince: DateTime(2019, 3, 14),
  );

  /// Returns fresh copies so a logout can reset balances.
  static List<Account> accounts() => [
        Account(
          id: 'acc_checking',
          name: 'Everyday Checking',
          number: '4012888812344821',
          type: AccountType.checking,
          balance: 12450.75,
        ),
        Account(
          id: 'acc_savings',
          name: 'High-Yield Savings',
          number: '4012888812349134',
          type: AccountType.savings,
          balance: 32800.00,
        ),
      ];

  static List<BankTransaction> transactions() {
    final now = DateTime.now();
    DateTime ago(int days, int hour, int minute) =>
        DateTime(now.year, now.month, now.day - days, hour, minute);

    return [
      BankTransaction(
        id: 'TX1001',
        title: 'Starbucks Coffee',
        subtitle: 'Food & Drink',
        amount: -6.45,
        date: ago(0, 8, 42),
        category: TxCategory.food,
      ),
      BankTransaction(
        id: 'TX1002',
        title: 'Received from Sarah Lee',
        subtitle: 'Dinner split',
        amount: 45.00,
        date: ago(0, 7, 15),
        category: TxCategory.transfer,
      ),
      BankTransaction(
        id: 'TX1003',
        title: 'Amazon',
        subtitle: 'Shopping',
        amount: -129.99,
        date: ago(1, 19, 30),
        category: TxCategory.shopping,
      ),
      BankTransaction(
        id: 'TX1004',
        title: 'Uber',
        subtitle: 'Transport',
        amount: -18.20,
        date: ago(1, 9, 5),
        category: TxCategory.transport,
      ),
      BankTransaction(
        id: 'TX1005',
        title: 'Acme Corp Payroll',
        subtitle: 'Salary',
        amount: 4250.00,
        date: ago(3, 9, 0),
        category: TxCategory.salary,
      ),
      BankTransaction(
        id: 'TX1006',
        title: 'Netflix',
        subtitle: 'Subscription',
        amount: -15.49,
        date: ago(4, 12, 0),
        category: TxCategory.entertainment,
      ),
      BankTransaction(
        id: 'TX1007',
        title: 'City Electric',
        subtitle: 'Utility bill',
        amount: -84.30,
        date: ago(5, 16, 20),
        category: TxCategory.bills,
      ),
      BankTransaction(
        id: 'TX1008',
        title: 'Whole Foods Market',
        subtitle: 'Groceries',
        amount: -76.12,
        date: ago(6, 18, 45),
        category: TxCategory.food,
      ),
      BankTransaction(
        id: 'TX1009',
        title: 'Transfer to John Carter',
        subtitle: 'Rent share',
        amount: -650.00,
        date: ago(8, 10, 10),
        category: TxCategory.transfer,
      ),
      BankTransaction(
        id: 'TX1010',
        title: 'Shell Gas Station',
        subtitle: 'Transport',
        amount: -52.80,
        date: ago(10, 17, 35),
        category: TxCategory.transport,
      ),
    ];
  }

  static const contacts = [
    Contact(
      id: 'c1',
      name: 'Sarah Lee',
      bank: 'Demo Bank',
      accountNumber: '5500123412347788',
      color: Color(0xFFE67E22),
    ),
    Contact(
      id: 'c2',
      name: 'John Carter',
      bank: 'First National',
      accountNumber: '5500123412342210',
      color: Color(0xFF16A085),
    ),
    Contact(
      id: 'c3',
      name: 'Emma Wilson',
      bank: 'City Credit Union',
      accountNumber: '5500123412345563',
      color: Color(0xFF8E44AD),
    ),
    Contact(
      id: 'c4',
      name: 'Michael Brown',
      bank: 'Demo Bank',
      accountNumber: '5500123412349901',
      color: Color(0xFFD81B60),
    ),
    Contact(
      id: 'c5',
      name: 'Olivia Davis',
      bank: 'Metro Savings',
      accountNumber: '5500123412340047',
      color: Color(0xFF3A6FF7),
    ),
  ];
}
