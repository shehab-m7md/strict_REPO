import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PhoneAuthScreen(),
    );
  }
}

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  String? verificationId;
  String? uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Phone Auth")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone (+201234567890)"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: phoneController.text.trim(),
                  verificationCompleted: (PhoneAuthCredential credential) async {
                    final user = await FirebaseAuth.instance.signInWithCredential(credential);
                    setState(() => uid = user.user?.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Auto Verified & Signed In")),
                    );
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.message}")),
                    );
                  },
                  codeSent: (String verId, int? resendToken) {
                    setState(() => verificationId = verId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code Sent via SMS")),
                    );
                  },
                  codeAutoRetrievalTimeout: (String verId) {
                    setState(() => verificationId = verId);
                  },
                );
              },
              child: const Text("Send Code"),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "Enter SMS Code"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (verificationId != null) {
                  final credential = PhoneAuthProvider.credential(
                    verificationId: verificationId!,
                    smsCode: codeController.text.trim(),
                  );
                  final user = await FirebaseAuth.instance.signInWithCredential(credential);
                  setState(() => uid = user.user?.uid);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signed In Successfully")),
                  );
                }
              },
              child: const Text("Verify & Sign In"),
            ),
            const SizedBox(height: 20),
            Text(uid == null ? "Not signed in" : "UID: $uid"),
          ],
        ),
      ),
    );
  }
}