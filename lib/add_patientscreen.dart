import 'package:flutter/material.dart';
import 'package:project/patient_listscreen.dart';

class AddPatientscreen extends StatelessWidget {
  const AddPatientscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Patient Details"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Patient Details",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Full Name", Icons.person),
                  _buildTextField("Age", Icons.calendar_today, isNumber: true),
                  _buildTextField("Address", Icons.home),
                  _buildTextField("Details", Icons.home),
                  _buildTextField("Medical History", Icons.history),
                  _buildTextField("Temperature", Icons.heat_pump),
                  _buildTextField("Blood Pressure", Icons.monitor_heart),
                  _buildTextField("Heart Rate", Icons.favorite),
                  _buildTextField("Respiratory Rate", Icons.air),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigation to do action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PatientListscreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text("Add Patient"),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

// Reusable Textfield widget
Widget _buildTextField(String label, IconData icon, {bool isNumber = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    ),
  );
}
