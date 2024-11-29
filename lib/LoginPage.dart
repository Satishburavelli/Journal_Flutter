import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String predefinedUsername = "user123";
  final String predefinedPassword = "pass123";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: Center(

          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  child: Image.asset(
                    'assets/TRAVEL.png',
                    width: 190,
                    height: 120,
                  ),
                ),
                Container(

                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 50.0),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(45.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Center(
                              child: Text(
                            "Welcome!",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.pink,
                            ),
                          )),
                          const SizedBox(height: 20),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Username",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: TextField(
                              style: TextStyle(color: Colors.white70),
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your username',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  " Password ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: TextField(
                              style: TextStyle(color: Colors.white70),

                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Enter your password',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_usernameController.text ==
                                      predefinedUsername &&
                                  _passwordController.text ==
                                      predefinedPassword) {
                                Navigator.pushNamed(context, '/MainScreen');
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Login Failed"),
                                        content: const Text(
                                            "Incorrect Username or Password"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("ok"),
                                          )
                                        ],
                                      );
                                    });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 19),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
