import 'package:flutter/material.dart';
import 'package:project/add_patientscreen.dart';

class PatientListscreen extends StatelessWidget {
  //final TextEditingController searchController;
  //final Function(String) onSearch;

  const PatientListscreen({super.key});
  //required this.searchController, required this.onSearch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("List of Patients"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Patient Lists",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigation to do action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddPatientscreen()),
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
        ));
  }
}
