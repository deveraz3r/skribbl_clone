import 'package:flutter/material.dart';
import 'package:skribbl_clone/resources/app_colors.dart';

class ReuseableElevatedbutton extends StatelessWidget {
  const ReuseableElevatedbutton({
    super.key,
    required this.buttonName,
    this.onPressed,
    this.width = double.infinity,
  });

  final String buttonName;
  final VoidCallback? onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {},
      child: Container(
        width: width,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.blue,
        ),
        child: Center(
            child: Text(
          buttonName,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        )),
      ),
    );
  }
}
