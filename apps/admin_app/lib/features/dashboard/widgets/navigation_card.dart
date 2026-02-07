import 'package:flutter/material.dart';

/// Navigation card widget for quick actions
class NavigationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const NavigationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final avatarRadius = constraints.maxHeight * 0.25;
            final iconSize = avatarRadius * 0.8;
            return Padding(
              padding: EdgeInsets.all(constraints.maxWidth * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 3,
                    child: CircleAvatar(
                      radius: avatarRadius.clamp(25, 40),
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(
                        icon,
                        color: color,
                        size: iconSize.clamp(20, 32),
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Flexible(
                    flex: 1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
