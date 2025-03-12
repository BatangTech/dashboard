import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  String getGreeting() {
    int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning,";
    } else if (hour >= 12 && hour < 18) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: getGreeting(),
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold , color: Color.fromARGB(255, 8, 64, 110)),
              ),
              TextSpan(
                text: "\nAdmin",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 8, 64, 110)),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50), // เพิ่มระยะห่างระหว่างไอคอน
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.account_circle),
                    onPressed: () {},
                  ),
                  Text('Profile', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
