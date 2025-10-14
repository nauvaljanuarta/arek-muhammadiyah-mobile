import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';

class CustomAppBar extends StatelessWidget {
  final dynamic currentUser;

  const CustomAppBar({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/images/muhammadiyahlogo.png",
                  width: 52,
                  height: 52,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Muhammadiyah',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
