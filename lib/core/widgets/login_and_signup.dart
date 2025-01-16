import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/user_data_util.dart';
import '../../../helpers/app_regex.dart';
import '../../../routing/routes.dart';
import '../../../theming/styles.dart';
import '../../helpers/extensions.dart';
import 'app_text_button.dart';
import 'app_text_form_field.dart';
import 'password_validations.dart';
import '../../core/widgets/loading_dialog.dart';

// ignore: must_be_immutable
class EmailAndPassword extends StatefulWidget {
  final bool? isSignUpPage;
  final bool? isPasswordPage;
  late GoogleSignInAccount? googleUser;
  late OAuthCredential? credential;
  EmailAndPassword({
    super.key,
    this.isSignUpPage,
    this.isPasswordPage,
    this.googleUser,
    this.credential,
  });

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  bool isObscureText = true;
  bool hasLowercase = false;
  bool hasUppercase = false;
  late final _auth = FirebaseAuth.instance;

  bool hasNumber = false;
  bool hasMinLength = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  final passwordFocuseNode = FocusNode();
  final passwordConfirmationFocuseNode = FocusNode();

  @override
  void initState() {
    super.initState();
    setupPasswordControllerListener();
    checkForPasswordFocused();
    checkForPasswordConfirmationFocused();
  }

  void checkForPasswordFocused() {
    passwordFocuseNode.addListener(() {
      if (passwordFocuseNode.hasFocus && isObscureText) {
      } else if (!passwordFocuseNode.hasFocus && isObscureText) {}
    });
  }

  void checkForPasswordConfirmationFocused() {
    passwordConfirmationFocuseNode.addListener(() {
      if (passwordConfirmationFocuseNode.hasFocus && isObscureText) {
      } else if (!passwordConfirmationFocuseNode.hasFocus && isObscureText) {}
    });
  }

  void setupPasswordControllerListener() {
    passwordController.addListener(() {
      setState(() {
        hasLowercase = AppRegex.hasLowerCase(passwordController.text);
        hasUppercase = AppRegex.hasUpperCase(passwordController.text);
        hasNumber = AppRegex.hasNumber(passwordController.text);
        hasMinLength = AppRegex.hasMinLength(passwordController.text);
      });
    });
  }

  Widget forgetPasswordTextButton(BuildContext context) {
    if (widget.isSignUpPage == null && widget.isPasswordPage == null) {
      return TextButton(
        onPressed: () {
          context.pushNamed(Routes.forgetScreen);
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Lupa Password?',
            style: TextStyles.font14Blue400Weight,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  loginOrSignUpOrPasswordButton(BuildContext context) {
    if (widget.isSignUpPage == true) {
      return signUpButton(context);
    }
    if (widget.isSignUpPage == null && widget.isPasswordPage == null) {
      return loginButton(context);
    }
  }

  AppTextButton signUpButton(BuildContext context) {
    return AppTextButton(
      buttonText: "Buat Akun",
      textStyle: TextStyles.font16White600Weight,
      onPressed: () async {
        passwordFocuseNode.unfocus();
        passwordConfirmationFocuseNode.unfocus();

        if (formKey.currentState!.validate()) {
          showLoadingDialog(context);
          try {
            // Buat akun pengguna
            UserCredential userCredential =
                await _auth.createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

            // Update nama pengguna di Firebase Authentication
            await _auth.currentUser!.updateDisplayName(nameController.text);

            // Kirim email verifikasi
            await _auth.currentUser!.sendEmailVerification();

            // Simpan data pengguna di Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'name': nameController.text, // Simpan nama pengguna di Firestore
              'dataComplete': false,
              'role': 'orang tua',
            });

            // Logout setelah pendaftaran berhasil
            await _auth.signOut();

            if (!context.mounted) return;

            Navigator.pop(context);

            await AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'Registrasi Berhasil',
              desc: 'Jangan lupa untuk verifikasi email, periksa kotak masuk.',
            ).show();

            await Future.delayed(const Duration(seconds: 2));

            if (!context.mounted) return;

            context.pushNamedAndRemoveUntil(
              Routes.loginScreen,
              predicate: (route) => false,
            );
          } on FirebaseAuthException catch (e) {
            if (e.code == 'email-already-in-use') {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'Error',
                desc: 'Akun ini sudah ada, silakan login.',
              ).show();
            } else {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'Error',
                desc: e.message,
              ).show();
            }
          } catch (e) {
            Navigator.pop(context);
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'Error',
              desc: e.toString(),
            ).show();
          }
        }
      },
    );
  }

  Future<bool> checkParentDataComplete(String uid) async {
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
  }

  AppTextButton loginButton(BuildContext context) {
    return AppTextButton(
      buttonText: 'Masuk',
      textStyle: TextStyles.font16White600Weight,
      onPressed: () async {
        passwordFocuseNode.unfocus();

        if (formKey.currentState!.validate()) {
          showLoadingDialog(context);
          try {
            final c = await _auth.signInWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

            Navigator.pop(context);

            if (c.user!.emailVerified) {
              bool isParentDataComplete =
                  await checkParentDataComplete(c.user!.uid);
              bool isChildDataComplete =
                  await UserDataUtil.checkUserDataComplete(c.user!.uid);

              await Future.delayed(const Duration(seconds: 2));

              if (!context.mounted) return;

              if (isParentDataComplete) {
                if (isChildDataComplete) {
                  context.pushNamedAndRemoveUntil(
                    Routes.homeScreen,
                    predicate: (route) => false,
                  );
                } else {
                  context.pushNamedAndRemoveUntil(
                    Routes.childForm,
                    predicate: (route) => false,
                    arguments: {'userId': c.user!.uid},
                  );
                }
              } else {
                context.pushNamedAndRemoveUntil(
                  Routes.parentForm,
                  predicate: (route) => false,
                  arguments: {'userId': c.user!.uid},
                );
              }
            } else {
              await _auth.signOut();

              if (!context.mounted) return;

              AwesomeDialog(
                context: context,
                dialogType: DialogType.info,
                animType: AnimType.rightSlide,
                title: 'Email Belum Diverifikasi',
                desc: 'Silakan periksa email Anda dan verifikasi.',
              ).show();
            }
          } on FirebaseAuthException catch (e) {
            Navigator.pop(context);
            if (e.code == 'user-not-found') {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'FireBase Error',
                desc: 'Tidak ada pengguna yang ditemukan untuk email tersebut.',
              ).show();
            } else if (e.code == 'wrong-password') {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'Error',
                desc: 'Password yang dimasukkan salah.',
              ).show();
            } else {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'Error',
                desc: e.message,
              ).show();
            }
          }
        }
      },
    );
  }

  Widget emailField() {
    if (widget.isPasswordPage == null) {
      return Column(
        children: [
          AppTextFormField(
            hint: 'Email',
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !AppRegex.isEmailValid(value)) {
                return 'Masukkan email yang valid';
              }
            },
            controller: emailController,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget nameField() {
    if (widget.isSignUpPage == true) {
      return Column(
        children: [
          AppTextFormField(
            hint: 'Nama',
            validator: (value) {
              if (value == null || value.isEmpty || value.startsWith(' ')) {
                return 'Masukkan nama yang valid';
              }
            },
            controller: nameController,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  AppTextFormField passwordField() {
    return AppTextFormField(
      focusNode: passwordFocuseNode,
      controller: passwordController,
      hint: 'Password',
      isObscureText: isObscureText,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            if (isObscureText) {
              isObscureText = false;
            } else {
              isObscureText = true;
            }
          });
        },
        child: Icon(
          isObscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
      ),
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            !AppRegex.isPasswordValid(value)) {
          return 'Masukkan password yang valid';
        }
      },
    );
  }

  Widget passwordConfirmationField() {
    if (widget.isSignUpPage == true || widget.isPasswordPage == true) {
      return AppTextFormField(
        focusNode: passwordConfirmationFocuseNode,
        controller: passwordConfirmationController,
        hint: 'Konfirmasi Password',
        isObscureText: isObscureText,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              if (isObscureText) {
                isObscureText = false;
              } else {
                isObscureText = true;
              }
            });
          },
          child: Icon(
            isObscureText ? Icons.visibility_off : Icons.visibility,
          ),
        ),
        validator: (value) {
          if (value != passwordController.text) {
            return 'Masukkan password yang cocok';
          }
          if (value == null ||
              value.isEmpty ||
              !AppRegex.isPasswordValid(value)) {
            return 'Masukkan password yang valid';
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 18),
          SizedBox(
            height: MediaQuery.of(context).size.height / 5,
            child: widget.isSignUpPage == true
                ? Lottie.asset('assets/lottie/register_image.json')
                : Lottie.asset('assets/lottie/login_image.json'),
          ),
          Gap(18.h),
          nameField(),
          emailField(),
          passwordField(),
          Gap(18.h),
          passwordConfirmationField(),
          forgetPasswordTextButton(context),
          Gap(10.h),
          if (widget.isSignUpPage == true)
            PasswordValidations(
              hasLowerCase: hasLowercase,
              hasUpperCase: hasUppercase,
              hasNumber: hasNumber,
              hasMinLength: hasMinLength,
            ),
          Gap(20.h),
          loginOrSignUpOrPasswordButton(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    passwordConfirmationController.dispose();
    emailController.dispose();
    nameController.dispose();
    passwordFocuseNode.dispose();
    passwordConfirmationFocuseNode.dispose();
    super.dispose();
  }
}
