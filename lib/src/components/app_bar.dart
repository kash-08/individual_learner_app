import 'package:flutter/material.dart';

class LearningAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;

  const LearningAppBar({
    Key? key,
    required this.title,
    required this.subtitle,
    this.backgroundColor = const Color(0xFF4361EE),
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      // Optional: Add actions if needed
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.notifications, color: textColor),
      //     onPressed: () {},
      //   ),
      // ],
    );
  }
}

// Alternative custom app bar with more control
class CustomLearningAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final List<Widget>? actions;

  const CustomLearningAppBar({
    Key? key,
    required this.title,
    required this.subtitle,
    this.backgroundColor = const Color(0xFF4361EE),
    this.textColor = Colors.white,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// Usage example in a Scaffold:
/*
Scaffold(
  appBar: LearningAppBar(
    title: "Learning Dashboard",
    subtitle: "Track your progress and continue learning",
    backgroundColor: Color(0xFF4361EE), // Blue background
    textColor: Colors.white, // White text for contrast
  ),
  body: YourContentHere(),
)
*/

// Alternative color schemes you can use:
class AppBarThemes {
  static const Color primaryBlue = Color(0xFF4361EE);
  static const Color darkBlue = Color(0xFF3A56D4);
  static const Color deepPurple = Color(0xFF7209B7);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color professionalNavy = Color(0xFF2C3E50);
}