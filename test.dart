import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  TextEditingController nameController =
      TextEditingController();

  TextEditingController ageController =
      TextEditingController();
//=================================================================
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref("user");
// ================================================================

  Future<void> createData() async {
    await ref.set({
      "name": "Ahmed",
      "age": 20,
    });

  }

// ===============================================================
 

  Future<void> updateData() async {

    await ref.update({
      "name": nameController.text,
      "age": int.parse(ageController.text),
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Firebase Demo"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // =========================
            // STREAMBUILDER
            // READ DATA
            // =========================

            StreamBuilder<DatabaseEvent>(

              stream: ref.onValue,

              builder: (context, snapshot) {

                // LOADING
                if(snapshot.connectionState ==
                    ConnectionState.waiting){

                  return const CircularProgressIndicator();
                }

                // ERROR
                if(snapshot.hasError){

                  return const Text("Error");
                }

                // HAS DATA
                if(snapshot.hasData){

                  // GET FIREBASE DATA
                  final data =
                    snapshot.data!.snapshot.value
                      as Map<dynamic,dynamic>;

                  // READ VALUES
                  String name = data['name'];
                  int age = data['age'];

                  // SHOW VALUES
                  return Column(
                    children: [

                      Text(
                        "Name : $name",
                        style: const TextStyle(fontSize: 22),
                      ),

                      Text(
                        "Age : $age",
                        style: const TextStyle(fontSize: 22),
                      ),

                    ],
                  );
                }

                return const Text("No data");
              },
            ),

            const SizedBox(height: 30),

            // =========================
            // TEXTFIELDS
            // =========================

            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: "New Name",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: ageController,

              decoration: const InputDecoration(
                labelText: "New Age",
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // CREATE BUTTON
            // =========================

            ElevatedButton(

              onPressed: createData,

              child: const Text("SET DATA"),
            ),

            const SizedBox(height: 20),

            // =========================
            // UPDATE BUTTON
            // =========================

            ElevatedButton(

              onPressed: updateData,

              child: const Text("UPDATE DATA"),
            ),

          ],
        ),
      ),
    );
  }
}