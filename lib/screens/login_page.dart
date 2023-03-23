import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/firebase_auth_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController imageController = TextEditingController();

  TextEditingController emailSignInController = TextEditingController();
  TextEditingController passwordSignInController = TextEditingController();

  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text(
                "Sign Up",
              ),
              onPressed: () {
                validateAndSignUpUser(context);
              },
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              child: const Text(
                "Sign In",
              ),
              onPressed: () {
                validateAndSignInUser(context);
              },
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = await FirebaseAuthHelper.firebaseAuthHelper
                    .logInWithAnonymously();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Login Successful..."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (user != null) {
                  Navigator.of(context).pushReplacementNamed("/");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Login Failed..."),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Anonymous Login"),
            ),
          ],
        ),
      ),
    );
  }

  validateAndSignUpUser(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Sign Up"),
        ),
        content: Form(
          key: signUpFormKey,
          child: SizedBox(
            height: 250,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter The Name...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      email = val;
                    },
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Enter The Name...",
                      label: Text("Name"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    validator: (val) =>
                        (val!.isEmpty) ? "Enter The Password..." : null,
                    keyboardType: TextInputType.visiblePassword,
                    onSaved: (val) {
                      password = val;
                    },
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: "Enter The Password...",
                      label: Text("Password"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (signUpFormKey.currentState!.validate()) {
                signUpFormKey.currentState!.save();

                User? user = await FirebaseAuthHelper.firebaseAuthHelper
                    .signUp(email: email!, password: password!);

                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sign Up Successful\n UID: ${user.uid}"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sign Up Failed..."),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                print("============================");
                print(email);
                print(password);
                print("============================");
              }
              emailController.clear();
              passwordController.clear();

              setState(() {
                email = null;
                password = null;
              });

              Navigator.of(context).pop();
            },
            child: const Text(
              "Sign Up",
            ),
          ),
          OutlinedButton(
            onPressed: () {
              emailController.clear();
              passwordController.clear();

              setState(() {
                email = null;
                password = null;
              });

              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
            ),
          ),
        ],
      ),
    );
  }

  validateAndSignInUser(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Sign Up"),
        ),
        content: Form(
          key: signInFormKey,
          child: Container(
            height: 250,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter The Name...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      email = val;
                    },
                    controller: emailSignInController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Enter The Name...",
                      label: Text("Name"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    validator: (val) =>
                        (val!.isEmpty) ? "Enter The Password..." : null,
                    keyboardType: TextInputType.visiblePassword,
                    onSaved: (val) {
                      password = val;
                    },
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: "Enter The Password...",
                      label: Text("Password"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (signInFormKey.currentState!.validate()) {
                signInFormKey.currentState!.save();

                User? user = await FirebaseAuthHelper.firebaseAuthHelper
                    .signIn(email: email!, password: password!);

                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sign In Successful\n UID: ${user.uid}"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  Navigator.of(context).pop();

                  Navigator.of(context)
                      .pushReplacementNamed('HomePage', arguments: user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sign In Failed..."),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  emailSignInController.clear();
                  passwordSignInController.clear();
                  setState(() {
                    email = null;
                    password = null;
                  });
                  Navigator.of(context).pop();
                }

                print("============================");
                print(email);
                print(password);
                print("============================");
              }
            },
            child: const Text(
              "Sign In",
            ),
          ),
          OutlinedButton(
            onPressed: () {
              emailSignInController.clear();
              passwordSignInController.clear();

              setState(() {
                email = null;
                password = null;
              });

              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
            ),
          ),
        ],
      ),
    );
  }
}
