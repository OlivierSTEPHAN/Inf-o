import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
        ),
      ),
      child: const Center(
        heightFactor: 50,
        widthFactor: 50,
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }
}
