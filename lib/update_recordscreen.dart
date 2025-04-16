import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class UpdatePatientRecordScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const UpdatePatientRecordScreen({super.key, required this.patient});

  @override
  _UpdatePatientRecordScreenState createState() =>
      _UpdatePatientRecordScreenState();
}

class _UpdatePatientRecordScreenState extends State<UpdatePatientRecordScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController addressController;
  late TextEditingController medicalHistoryController;
  late TextEditingController contactInfoController;
  late TextEditingController roomNumberController;

  final String connectionString =
      'mongodb://admin:1234@ac-uru0tue-shard-00-00.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-01.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-02.pl66lr6.mongodb.net:27017/?replicaSet=atlas-4lamuj-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=flutterProject';

  mongo.Db? db;
  mongo.DbCollection? collection;

  @override
  void initState() {
    super.initState();
    _connectToMongoDB();

    // Initialize controllers with data
    nameController = TextEditingController(text: widget.patient["fullName"]);
    ageController =
        TextEditingController(text: widget.patient["age"].toString());
    addressController = TextEditingController(text: widget.patient["address"]);
    medicalHistoryController =
        TextEditingController(text: widget.patient["medicalHistory"]);
    contactInfoController =
        TextEditingController(text: widget.patient["contactInfo"].toString());
    roomNumberController =
        TextEditingController(text: widget.patient["roomNumber"].toString());
  }

  Future<void> _connectToMongoDB() async {
    try {
      db = mongo.Db(connectionString);
      await db!.open();
      collection = db!.collection('patients');
    } catch (e, stackTrace) {
      print("❌ MongoDB connection error: $e");
    }
  }

  Future<void> saveUpdatedPatient() async {
    if (db == null || collection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MongoDB connection failed')),
      );
      return;
    }

    late mongo.ObjectId objectId;
    final rawId = widget.patient['_id'];

    try {
      if (rawId is mongo.ObjectId) {
        objectId = rawId;
      } else if (rawId is Map && rawId['\$oid'] != null) {
        objectId = mongo.ObjectId.parse(rawId['\$oid']);
      } else if (rawId is String) {
        String formattedId = rawId;
        if (formattedId.startsWith("ObjectId(")) {
          formattedId =
              formattedId.replaceAll('ObjectId("', '').replaceAll('")', '');
        }
        objectId = mongo.ObjectId.parse(formattedId);
      } else {
        throw Exception("Invalid _id format");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid patient ID format')),
      );
      return;
    }

    int age = int.tryParse(ageController.text) ?? -1;
    if (age <= 0 || age > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return;
    }

    try {
      var result = await collection!.updateOne(
        {'_id': objectId},
        mongo.ModifierBuilder()
          ..set('fullName', nameController.text)
          ..set('age', age)
          ..set('address', addressController.text)
          ..set('medicalHistory', medicalHistoryController.text)
          ..set('contactInfo', contactInfoController.text)
          ..set('roomNumber', roomNumberController.text),
      );

      if (result.isSuccess && result.nModified > 0) {
        final updatedPatient = {
          '_id': objectId,
          'fullName': nameController.text,
          'age': age,
          'address': addressController.text,
          'medicalHistory': medicalHistoryController.text,
          'contactInfo': contactInfoController.text,
          'roomNumber': roomNumberController.text,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient record updated successfully!')),
        );

        Navigator.pop(context, updatedPatient);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No changes made to the patient record')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update patient record')),
      );
    }
  }

  @override
  void dispose() {
    db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Patient Record",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Full Name", Icons.person,
                  controller: nameController),
              _buildTextField("Age", Icons.calendar_today,
                  controller: ageController, isNumber: true),
              _buildTextField("Address", Icons.home,
                  controller: addressController),
              _buildTextField("Medical History", Icons.history,
                  controller: medicalHistoryController),
              _buildTextField("Contact Info", Icons.contact_phone,
                  controller: contactInfoController),
              _buildTextField("Room Number", Icons.location_on,
                  controller: roomNumberController),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: saveUpdatedPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Update Record",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {bool isNumber = false, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
        ),
      ),
    );
  }
}
