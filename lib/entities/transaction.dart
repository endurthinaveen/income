import 'package:flutter/cupertino.dart';

class TransactionEntity {
  final String title;
  final String subtitle;
  final String time;
  final double amount;
  final bool isIncome;
  final String category;
  final IconData icon;
  final Color color;
  final DateTime dateTime;


  TransactionEntity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.icon,
    required this.color,
    required this.dateTime,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) => TransactionEntity(
    title: json['title'],
    subtitle: json['subtitle'],
    time: json['time'],
    amount: json['amount'],
    isIncome: json['isIncome'],
    category: json['category'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    color: Color(json['color']),
    dateTime: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
        : DateTime.now(),

  );


  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'time': time,
    'amount': amount,
    'isIncome': isIncome,
    'category': category,
    'icon': icon.codePoint,
    'color': color.value,
    'timestamp': dateTime.toIso8601String(),
  };
}
