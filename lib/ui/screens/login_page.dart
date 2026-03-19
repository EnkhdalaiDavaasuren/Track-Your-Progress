import 'package:flutter/material.dart';
import 'package:my_app/services/track_manager.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget
{
 const LoginPage({super.key});

 @override
 State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
 final _emailController = TextEditingController();
 final _passController = TextEditingController();
 bool isLogin = true; // Toggle between Login and Sign Up

 void _showForgotPasswordDialog()
 {
  final resetController = TextEditingController(text: _emailController.text);

  showDialog(
   context: context,
   builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Text("Reset Password"),
    content: Column(
     mainAxisSize: MainAxisSize.min,
     children: [
      const Text("We will send a reset link to your email."),
      const SizedBox(height: 15),
      TextField(
       controller: resetController,
       decoration: const InputDecoration(
        hintText: "Enter your email",
        border: OutlineInputBorder()
       )
      )
     ]
    ),
    actions: [
     TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("CANCEL")
     ),
     ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      onPressed: () async
      {
       final error = await AuthService().resetPassword(resetController.text);
       Navigator.pop(context);

       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? "Reset email sent! Check your inbox."))
       );
      },
      child: const Text("SEND LINK", style: TextStyle(color: Colors.white))
     )
    ]
   )
  );
 }

 // Inside _handleAuth in login_page.dart
 void _handleAuth() async
 {
  final auth = AuthService();
  String? error;

  if (isLogin)
  {
   error = await auth.login(_emailController.text, _passController.text);
  }
  else
  {
   error = await auth.signUp(_emailController.text, _passController.text);
  }

  if (error == null)
  {
   // SUCCESS! Now fetch the data
   if (mounted)
   {
    await context.read<TrackManager>().loadFromFirebase();
   }
  }
  else if (mounted)
  {
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
 }

 @override
 Widget build(BuildContext context)
 {
  return Scaffold(
   body: Padding(
    padding: const EdgeInsets.all(30.0),
    child: Column(
     mainAxisAlignment: MainAxisAlignment.center,
     children: [
      Text(isLogin ? "LOGIN" : "SIGN UP", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      TextField(
       controller: _emailController,
       decoration: const InputDecoration(hintText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.zero))
      ),
      const SizedBox(height: 15),
      TextField(
       controller: _passController,
       obscureText: true,
       decoration: const InputDecoration(hintText: "Password", border: OutlineInputBorder(borderRadius: BorderRadius.zero))
      ),
      const SizedBox(height: 30),
      // Boxy Button
      SizedBox(
       width: double.infinity,
       height: 55,
       child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
        onPressed: _handleAuth,
        child: Text(isLogin ? "LOGIN" : "CREATE ACCOUNT", style: const TextStyle(color: Colors.white))
       )
      ),
      TextButton(
       onPressed: () => setState(() => isLogin = !isLogin),
       child: Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login")
      ),
      TextButton(
       onPressed: _showForgotPasswordDialog,
       child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey))
      )
     ]
    )
   )
  );
 }
}
