import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CounterWithFavBtn extends StatelessWidget {
  const CounterWithFavBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        // CartCounter(),
        Container(
          padding: const EdgeInsets.all(8),
          height: 32,
          width: 32,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset("assets/icons/heart_disabled.svg"),
        )
      ],
    );
  }
}
