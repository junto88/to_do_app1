import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Le password non corrispondono';
      });
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Invia una mail di verifica
      final user = userCredential.user;
      await user?.sendEmailVerification();

      setState(() {
        _errorMessage = 'Registrazione completata. Verifica la tua email.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore di registrazione: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrati', style: GoogleFonts.poppins())),
       backgroundColor: Colors.brown.shade200,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                cursorColor: Colors.brown,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.brown), border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown, width: 3.0)),
                  filled: true,
                      fillColor: Colors.white54
                ),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                cursorColor: Colors.brown,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.brown), border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown, width: 3.0)),
                  filled: true,
                      fillColor: Colors.white54
                ),
                obscureText: true,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),
              TextField(
                cursorColor: Colors.brown,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Conferma Password',labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.brown), border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown, width: 3.0)),
                  filled: true,
                      fillColor: Colors.white54
                ),
                obscureText: true,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,fontWeight: FontWeight.bold),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white54),
                child: Text('Registrati', style: GoogleFonts.poppins(color: Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Hai già un account? Accedi qui', style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
