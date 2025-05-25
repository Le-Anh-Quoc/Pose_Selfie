import 'package:flutter/material.dart';
import 'package:pose_selfie_app/src/constants/app_constants.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tutorial Image
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      20), // điều chỉnh độ bo tròn tại đây
                  child: Image.asset(
                    'assets/images/tutorial.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Instruction Text
            const Text(
              'Match your pose with the outline,\npress record, and capture.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSize.normal, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Okay Button
            SizedBox(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.yellowButton,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Okay!',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BowlbyOne',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
