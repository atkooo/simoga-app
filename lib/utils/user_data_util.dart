import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataUtil {
  static Future<bool> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('seen') ?? false);

    if (!seen) {
      await prefs.setBool('seen', true);
      return true;
    }

    return false;
  }

  static Future<bool> checkUserDataComplete(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'dataComplete': false,
        });
        return false;
      }

      if (userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['dataComplete'] ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Tambahkan metode ini
  static Future<bool> checkParentDataComplete(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return false;
      }

      if (userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['parentDataComplete'] ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
