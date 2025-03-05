import 'package:flutter/material.dart';
import 'package:project/add_patientscreen.dart';
import 'package:project/patient_listscreen.dart';

// void main() {
//   runApp(MainApp());
// }

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainApp(), // Set Screen to display
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Keeps the column tight to its content
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30), // Moves the logo up
                child: Image(
                  image: AssetImage('assets/medical-team.png'),
                  width: 150,
                  height: 150,
                ),
              ),
              const Text(
                'Welcome to Our App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(
                  height:
                      20), // to add the space between the text and the textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(height: 10), // to add space between the textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  obscureText: true, // Hides password input
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              const SizedBox(
                  height: 20), // space between the textfield and the buttin
              ElevatedButton(
                onPressed: () {
                  //  Navigate to the home screen when the user click login button
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PatientListscreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Login'),
              ),
              // const SizedBox(height: 20),
              // GestureDetector(
              //   onTap: () {
              //     // TODO: Navigate to the Register screen
              //   },
              //   child: RichText(
              //     text: const TextSpan(
              //       text: "Don't have an account? ",
              //       style: TextStyle(fontSize: 16, color: Colors.black),
              //       children: [
              //         TextSpan(
              //           text: "Register",
              //           style: TextStyle(
              //             fontSize: 16,
              //             color: Colors.blue,
              //             decoration: TextDecoration.underline,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
