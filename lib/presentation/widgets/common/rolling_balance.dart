import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RollingBalance extends StatefulWidget {
  final double balance;
  final TextStyle? style;
  final String currencySymbol;
  final bool showSign;

  const RollingBalance({
    super.key,
    required this.balance,
    this.style,
    this.currencySymbol = '',
    this.showSign = false,
  });

  @override
  State<RollingBalance> createState() => _RollingBalanceState();
}

class _RollingBalanceState extends State<RollingBalance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldBalance = 0;

  @override
  void initState() {
    super.initState();
    _oldBalance = widget.balance;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: widget.balance, end: widget.balance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
  }

  @override
  void didUpdateWidget(RollingBalance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _oldBalance = oldWidget.balance;
      _animation = Tween<double>(begin: _oldBalance, end: widget.balance).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        String text = formatter.format(value.abs());
        
        // Handle sign manually if needed, or just let the formatter do it if we passed signed value
        // But usually for financial apps we might want specific formatting for negative
        
        String prefix = '';
        if (widget.showSign) {
           if (value > 0) {
             prefix = '+';
           } else if (value < 0) {
             prefix = '-';
           }
        } else if (value < 0) {
           prefix = '-';
        }

        return Text(
          '$prefix${widget.currencySymbol} $text',
          style: widget.style,
        );
      },
    );
  }
}
