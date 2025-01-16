import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'extensions.dart';
import '../routing/routes.dart';
import '../core/widgets/loading_dialog.dart';
import '../utils/user_data_util.dart';

class GoogleSignin {
  static final _auth = FirebaseAuth.instance;

  static Future signInWithGoogle(BuildContext context) async {
    try {
      showLoadingDialog(context);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.of(context).pop();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      if (authResult.additionalUserInfo!.isNewUser) {
        Navigator.of(context).pop();
        context.pushNamedAndRemoveUntil(
          Routes.childForm,
          predicate: (route) => false,
        );
      } else {
        final user = _auth.currentUser!;
        bool isUserDataComplete =
            await UserDataUtil.checkUserDataComplete(user.uid);

        if (!isUserDataComplete) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'dataComplete': false,
          }, SetOptions(merge: true));
        }

        Navigator.of(context).pop(); // Close the loading dialog
        if (isUserDataComplete) {
          context.pushNamedAndRemoveUntil(
            Routes.homeScreen,
            predicate: (route) => false,
          );
        } else {
          context.pushNamedAndRemoveUntil(
            Routes.childList,
            predicate: (route) => false,
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Sign in error',
        desc: e.toString(),
      ).show();
    }
  }
}
