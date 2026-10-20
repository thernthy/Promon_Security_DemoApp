import 'package:flutter/material.dart';

import '../utils/format.dart';

class BankUser {
  const BankUser({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.customerId,
    required this.memberSince,
  });

  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String customerId;
  final DateTime memberSince;

  String get initials => initialsOf(fullName);
  String get firstName => fullName.split(' ').first;
}

enum AccountType { checking, savings }

class Account {
  Account({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.balance,
  });

  final String id;
  final String name;
  final String number;
  final AccountType type;
  double balance;

  String get last4 => number.substring(number.length - 4);
  String get masked => '•••• $last4';
}

enum TxCategory {
  transfer(Icons.swap_horiz_rounded, Color(0xFF3A6FF7)),
  shopping(Icons.shopping_bag_outlined, Color(0xFFE67E22)),
  food(Icons.restaurant_outlined, Color(0xFFE74C3C)),
  salary(Icons.payments_outlined, Color(0xFF00A86B)),
  bills(Icons.receipt_long_outlined, Color(0xFF8E44AD)),
  entertainment(Icons.movie_outlined, Color(0xFFD81B60)),
  transport(Icons.directions_car_outlined, Color(0xFF16A085));

  const TxCategory(this.icon, this.color);

  final IconData icon;
  final Color color;
}

class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.category,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Positive for money in, negative for money out.
  final double amount;
  final DateTime date;
  final TxCategory category;

  bool get isCredit => amount > 0;
}

class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.bank,
    required this.accountNumber,
    required this.color,
  });

  final String id;
  final String name;
  final String bank;
  final String accountNumber;
  final Color color;

  String get initials => initialsOf(name);
  String get maskedAccount =>
      '•••• ${accountNumber.substring(accountNumber.length - 4)}';
}
