// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class IconWidget extends StatelessWidget {
  final IconData icon;
  final int paddingLeft;
  final VoidCallback? onPressed;

  const IconWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.paddingLeft = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 35,
        maxHeight: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Padding(
          padding: EdgeInsets.only(left: paddingLeft.toDouble()),
          child: Icon(icon, color: Colors.white),
        ),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}

