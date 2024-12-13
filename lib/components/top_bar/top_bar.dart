import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class TopBar extends StatefulWidget {
  final String title;
  final bool showBackButton;
  const TopBar({super.key, required this.title,this.showBackButton = true});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  double conditionalPadding = 0;

   @override
  void initState() {
    super.initState();
    conditionalPadding = widget.showBackButton? 40: 10;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.only(top: 10), // Add top padding
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/top-bar.png'), // Replace with your image path
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the title

        children: [
          if (widget.showBackButton)
            IconButton(
              icon: Image.asset('assets/icons/back-arrow.png', height: 30),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
     
            Flexible(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(right: conditionalPadding),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}