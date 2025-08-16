import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final ValueChanged<Color> onColorSelected;
  const ColorPicker({super.key, required this.onColorSelected});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() => selectedColor = Colors.red);
            widget.onColorSelected(Colors.red);
          },
          child: CircleAvatar(backgroundColor: Colors.red),
        ),
        GestureDetector(
          onTap: () {
            setState(() => selectedColor = Colors.green);
            widget.onColorSelected(Colors.green);
          },
          child: CircleAvatar(backgroundColor: Colors.green),
        ),
        GestureDetector(
          onTap: () {
            setState(() => selectedColor = Colors.blue);
            widget.onColorSelected(Colors.blue);
          },
          child: CircleAvatar(backgroundColor: Colors.blue),
        ),
      ],
    );
  }
}
