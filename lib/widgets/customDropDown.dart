import 'package:flutter/material.dart';

import '../constants/styles.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String?>? onChanged;
  final String? value;
  final String? hintText;

  const CustomDropdown({super.key, 
    required this.options,
    this.onChanged,
    this.value,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text('${hintText ?? '--Select--'}'),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'select',
        hintStyle: text50010tcolor2,
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        border: InputBorder.none
      ),
    );
  }
}