import 'package:flutter/material.dart';

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? height;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  
  const ResponsiveCard({
    Key? key,
    required this.child,
    this.color,
    this.height,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust padding based on screen width
        final EdgeInsetsGeometry responsivePadding = constraints.maxWidth < 600
            ? EdgeInsets.all(padding.horizontal / 1.5)
            : padding;
            
        return Card(
          color: color,
          margin: margin,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: height,
              width: double.infinity,
              padding: responsivePadding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}