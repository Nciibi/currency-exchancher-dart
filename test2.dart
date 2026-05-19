import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DemoPage extends StatefulWidget {

  const DemoPage({super.key});

  @override
  State<DemoPage> createState() =>
      _DemoPageState();
}

class _DemoPageState
    extends State<DemoPage> {

  final _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      nameController =
      TextEditingController();

  final TextEditingController
      ageController =
      TextEditingController();

  bool isLoading = false;


  final DatabaseReference ref =
      FirebaseDatabase.instance
          .ref("user");
          
  Future<void> createData() async {

    await ref.set({

      "name": "Ahmed",

      "age": 20,

    });
  }

  // =========================
  // UPDATE DATA
  // =========================

  Future<void> updateData() async {

    // VALIDATE FORM
    if(!_formKey.currentState!
        .validate()) {

      return;
    }

    // START LOADING
    setState(() {

      isLoading = true;

    });

    try {

      // UPDATE FIREBASE
      await ref.update({

        "name":
          nameController.text,

        "age":
          int.parse(
            ageController.text),

      });

      // SUCCESS MESSAGE
      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
            Text("Updated successfully"),

          backgroundColor:
            Colors.green,
        ),
      );

    } catch(e){

      // ERROR MESSAGE
      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
            Text("Firebase Error"),

          backgroundColor:
            Colors.red,
        ),
      );

    }

    // STOP LOADING
    setState(() {

      isLoading = false;

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
          const Text("FULL FIREBASE DEMO"),
      ),

      body: Padding(

        padding:
          const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              // =========================
              // STREAMBUILDER
              // =========================

              StreamBuilder<DatabaseEvent>(

                stream: ref.onValue,

                builder:
                  (context, snapshot) {

                  // LOADING
                  if(snapshot.connectionState ==
                      ConnectionState.waiting){

                    return const
                      CircularProgressIndicator();
                  }

                  // ERROR
                  if(snapshot.hasError){

                    return const Text(
                      "Error loading data",
                    );
                  }

                  // HAS DATA
                  if(snapshot.hasData){

                    // GET FIREBASE DATA
                    final data =
                      snapshot.data!
                          .snapshot.value
                        as Map<dynamic,dynamic>;

                    // EXTRACT VALUES
                    String name =
                      data['name'];

                    int age =
                      data['age'];

                    // PRE-FILL TEXTFIELDS
                    nameController.text =
                        name;

                    ageController.text =
                        age.toString();

                    // SHOW DATA
                    return Column(

                      children: [

                        Text(

                          "Name : $name",

                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),

                        Text(

                          "Age : $age",

                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),

                      ],
                    );
                  }

                  return const Text(
                    "No data",
                  );
                },
              ),

              const SizedBox(height: 30),

              // =========================
              // NAME FIELD
              // =========================

              TextFormField(

                controller:
                  nameController,

                decoration:
                  const InputDecoration(

                    labelText: "Name",

                    border:
                      OutlineInputBorder(),
                  ),

                validator: (value){

                  if(value == null ||
                      value.isEmpty){

                    return
                      "Name required";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // =========================
              // AGE FIELD
              // =========================

              TextFormField(

                controller:
                  ageController,

                decoration:
                  const InputDecoration(

                    labelText: "Age",

                    border:
                      OutlineInputBorder(),
                  ),

                validator: (value){

                  // EMPTY
                  if(value == null ||
                      value.isEmpty){

                    return
                      "Age required";
                  }

                  // NUMBER CHECK
                  final age =
                    int.tryParse(value);

                  if(age == null){

                    return
                      "Invalid number";
                  }

                  // POSITIVE CHECK
                  if(age <= 0){

                    return
                      "Must be positive";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // =========================
              // SET BUTTON
              // =========================

              ElevatedButton(

                onPressed:
                  createData,

                child:
                  const Text("SET DATA"),
              ),

              const SizedBox(height: 20),

              // =========================
              // UPDATE BUTTON
              // =========================

              isLoading

              ? const CircularProgressIndicator()

              : ElevatedButton(

                  onPressed:
                    updateData,

                  child:
                    const Text("UPDATE"),
                ),

            ],
          ),
        ),
      ),
    );
  }
}