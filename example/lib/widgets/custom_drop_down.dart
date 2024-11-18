import 'package:flutter/material.dart';

import '../core/extensions.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String label;
  final ValueChanged<T?> onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.map((value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text((value as Enum).name.capitalize()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
