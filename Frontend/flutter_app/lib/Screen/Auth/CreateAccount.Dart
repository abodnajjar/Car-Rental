import 'package:flutter/material.dart';
import '../../api/SignUp.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _fullNameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();
  final _phoneC = TextEditingController();
  final _licenseC = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _fullNameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _confirmPasswordC.dispose();
    _phoneC.dispose();
    _licenseC.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final fullName = _fullNameC.text.trim();
    final email = _emailC.text.trim();
    final password = _passwordC.text;
    final confirm = _confirmPasswordC.text;
    final phone = _phoneC.text.trim();
    final license = _licenseC.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showMsg("Please fill full name, email and password");
      return;
    }
    if (password != confirm) {
      _showMsg("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    try {
      final api = AuthApi();
      final res = await api.signup(
        fullName: fullName,
        email: email,
        phone: phone,
        role: "customer", 
        password: password,
        drivingLicenseNo: license,
      );

      _showMsg("Registered ✅ ID: ${res["user_id"]}");

    } catch (e) {
      _showMsg("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Create Account",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Image.asset("assets/carRental.png", height: 100),

            const SizedBox(height: 20),

            const Text(
              "Create Your Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            inputField("Full Name", Icons.person, controller: _fullNameC),
            inputField("Email", Icons.email, controller: _emailC),
            inputField("Password", Icons.lock, obscure: true, controller: _passwordC),
            inputField("Confirm Password", Icons.lock_outline, obscure: true, controller: _confirmPasswordC),
            inputField("Phone Number", Icons.phone, controller: _phoneC),
            inputField("Driving License Number", Icons.card_membership, controller: _licenseC),

            const SizedBox(height: 25),

            SizedBox(
              width: 350,
              child: GestureDetector(
                onTap: _loading ? null : _signup,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: _loading
                        ? Colors.grey
                        : const Color.fromARGB(255, 66, 143, 176),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            "REGISTER",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                "Already have an account? Log In",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 25, 61, 169),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget inputField(
    String hint,
    IconData icon, {
    bool obscure = false,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        width: 350,
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
