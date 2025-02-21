import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:to_do_app/main.dart';
import 'RegistrationPage.dart';
import 'package:google_fonts/google_fonts.dart';



class AuthGate extends StatelessWidget {
  final VoidCallback onThemeChanged;

  AuthGate({required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomeScreen(onThemeChanged: onThemeChanged);
        }
        return LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    if (mounted) {
      setState(() => _isLoading = false);
    }

  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    if (mounted) {
      setState(() => _errorMessage = 'Errore Google: ${e.toString()}');
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false); 
    }
  }
}



  Future<void> _signInWithEmail() async {
    if (mounted) {
      setState(() => _isLoading = false);
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
  if (mounted) {
    setState(() => _errorMessage = 'Errore di accesso: ${e.toString()}');
  }
} finally {
  if (mounted) {
    setState(() => _isLoading = false);
  }
}

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container( 
            color: Colors.brown.shade200, 
            
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Login', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.login,color: Colors.black,),
                      label: Text("Accedi con Google",style: TextStyle(color: Colors.black)),
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white54)
                    ),
                    SizedBox(height: 10),
                    TextField(
                      cursorColor: Colors.brown,
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "Email",labelStyle: TextStyle(color: Colors.black),
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
                      decoration: InputDecoration(labelText: "Password",labelStyle: TextStyle(color: Colors.black),
                          floatingLabelStyle: TextStyle(color: Colors.brown), border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.brown, width: 3.0)),
                      filled: true,
                      fillColor: Colors.white54

                      ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,fontWeight: FontWeight.bold),
                          obscureText: true,
                      
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signInWithEmail,
                       style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white54),
                      child: Text("Accedi con Email",style: TextStyle(color: Colors.black),),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrationPage()),
                        );
                        
                      },
                      
                      child: Text("Non hai un account? Registrati",style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _isLoading ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withAlpha(128),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                ),
              ),
            ),
        ],
      ),
    );
  }
}