import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UpdateDoctorScreen(),
  ));
}

class UpdateDoctorScreen extends StatefulWidget {
  const UpdateDoctorScreen({super.key});

  @override
  State<UpdateDoctorScreen> createState() => _UpdateDoctorScreenState();
}

class _UpdateDoctorScreenState extends State<UpdateDoctorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _statusMessage = "";
  String? _docId;

  Future<void> _searchDoctor() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _statusMessage = "Please enter the patient name.";
        _docId = null;
      });
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _statusMessage = "Patient not found.";
        _docId = null;
        _ageController.clear();
        _doctorController.clear();
        _dateController.clear();
      });
    } else {
      final doctor = querySnapshot.docs.first;
      setState(() {
        _docId = doctor.id;
        _ageController.text = doctor['age'].toString();
        _doctorController.text = doctor['doctor'].toString();
        _dateController.text = doctor['date'].toString();
        _statusMessage = "Appointment loaded successfully.";
      });
    }
  }

  Future<void> _updateDoctor() async {
    if (_docId == null) {
      setState(() {
        _statusMessage = "Please search an appointment first.";
      });
      return;
    }

    final newAge = int.tryParse(_ageController.text.trim());
    final newDoctor = _doctorController.text.trim();
    final newDate = _dateController.text.trim();

    if (newAge == null || newDoctor == null || newDate==null) {
      setState(() {
        _statusMessage = "Please enter valid Age, Doctor and date.";
      });
      return;
    }

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(_docId)
        .update({
      'age': newAge,
      'doctor':newDoctor,
      'date':newDate
    });

    setState(() {
      _statusMessage = "Appointment updated successfully!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Appointment Details"),
        backgroundColor: const Color.fromARGB(255, 187, 0, 78),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Enter patient name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _searchDoctor,
                child: const Text("Search"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _doctorController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Doctor",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateDoctor,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Update"),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(
                    color: _statusMessage.contains("not") ||
                            _statusMessage.contains("Please")
                        ? Colors.red
                        : Colors.green,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
