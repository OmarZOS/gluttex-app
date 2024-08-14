import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IngredientCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String icon;
  final Function onClicked;

  const IngredientCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.icon,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClicked(); // Call the passed function when tapped
      },
      child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.string(
                    icon,
                    width: 40, // Set the desired width
                    height: 40, // Set the desired height
                    placeholderBuilder: (BuildContext context) =>
                        const CircularProgressIndicator(),
                  )),
              Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          quantity,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ]),
          )),
    );
  }
}
