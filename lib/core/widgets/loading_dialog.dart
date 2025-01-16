import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../theming/colors.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorsManager.mainBlue,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Memuat...',
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}

void showLoadingDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    body: const LoadingDialog(),
  ).show();
}
