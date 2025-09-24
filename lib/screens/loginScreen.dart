import 'package:chat_app/controllers/AuthController.dart';
import 'package:chat_app/providers/ThemeModeProvider.dart';
import 'package:chat_app/providers/loadingProviderAuth.dart';
import 'package:chat_app/screens/homeScreenNav.dart';
import 'package:chat_app/screens/signupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Loginscreen extends ConsumerWidget {
  Loginscreen({super.key});
  GlobalKey<FormState> formKey = GlobalKey();
  AuthController authController = AuthController();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeModeProvider.notifier).isDark();
    bool isLoading = ref.watch(loadingAuthProvider);
    final isLoadingRef = ref.read(loadingAuthProvider.notifier);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(themeModeProvider.notifier).toggleTheme();
        },
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.15,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 35,

                        child: Image.asset(
                          fit: BoxFit.contain,
                          isDark
                              ? 'assets/images/chatApp ui ux/Selection(dark).png'
                              : 'assets/images/chatApp ui ux/Selection.png',
                        ),
                      ),
                      Text(
                        'Halo',
                        style: GoogleFonts.montserrat(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Login to your Halo account to continue chatting!',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,

                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email'),
                    onSaved: (newValue) {
                      email = newValue ?? '';
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      String val = value ?? '';
                      if (val.trim().isEmpty) {
                        return 'Please fill your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(hintText: 'Password'),
                    validator: (value) {
                      String val = value ?? '';
                      if (val.trim().isEmpty) {
                        return 'Please fill your password';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      password = newValue ?? '';
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,

                                    content: const Text(
                                      'Please fill the form correctly',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                try {
                                  formKey.currentState!.save();
                                  isLoadingRef.set();
                                  await authController.logIn(email, password);
                                  isLoadingRef.reset();
                                  if (!authController
                                      .fireBaseAuth
                                      .currentUser!
                                      .emailVerified) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,

                                        content: const Text(
                                          'Please verify your email',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                    await authController.verifyAcc();
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomescreenNav(),
                                      ),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      content: Text(
                                        e.message ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                  isLoadingRef.reset();
                                }
                              }
                            },
                      child: const Text('LogIn'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        minimumSize: Size.zero,
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              formKey.currentState!.save();
                              if (email.trim().isNotEmpty) {
                                isLoadingRef.set();
                                await authController.resetPassword(email);
                                isLoadingRef.reset();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,

                                    content: const Text(
                                      'An email was sent to reset your password',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              } else
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    content: const Text(
                                      'Please fill in your email',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                            },
                      child: const Text('Forgot Password'),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account? '),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpscreen(),
                                  ),
                                );
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('SignUp'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Or SignIn with: '),
                  IconButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            isLoadingRef.set();
                            bool log = await authController.googleSignIn();
                            isLoadingRef.reset();
                            if (log)
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => HomescreenNav(),
                                ),
                              );
                          },
                    icon: const Icon(
                      FontAwesomeIcons.google,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
