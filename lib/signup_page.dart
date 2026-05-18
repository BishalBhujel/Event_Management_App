// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final nameController = TextEditingController();

//   bool isLoading = false;

//   final supabase = Supabase.instance.client;

//   Future<void> signUp() async {
//     setState(() => isLoading = true);

//     try {
//       final response = await supabase.auth.signUp(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       if (response.user != null) {
//         // Save extra user info in your users table
//         await supabase.from('users').insert({
//           'id': response.user!.id,
//           'email': emailController.text.trim(),
//           'full_name': nameController.text.trim(),
//           'role': 'normal_user',
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Signup successful!")),
//           );
//         }
//       }
//     } on AuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.message)),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Signup")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: "Full Name"),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),

//             isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: signUp,
//                     child: const Text("Sign Up"),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> signup() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        await supabase.from('users').insert({
          'id': response.user!.id,
          'email': emailController.text.trim(),
          'full_name': nameController.text.trim(),
          'role': 'normal_user',
        });

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : signup,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Sign Up"),
                      ),
                    ),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}