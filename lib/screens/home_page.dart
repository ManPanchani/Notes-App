import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_project/helpers/firebase_auth_helper.dart';
import '../helpers/firebase_db_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  TextEditingController titleUpDateController = TextEditingController();
  TextEditingController bodyUpDateController = TextEditingController();

  String? title;
  String? body;

  @override
  Widget build(BuildContext context) {
    User? data = ModalRoute.of(context)!.settings.arguments as User?;

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () async {
              await FirebaseAuthHelper.firebaseAuthHelper.logOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('LoginPage', (route) => false);
            },
          ),
        ],
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            const CircleAvatar(
              radius: 80,
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            (data != null) ? Text("Name: ${data.displayName}") : Container(),
            (data != null) ? Text("Email: ${data.email}") : Container(),
          ],
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("notes").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("ERROR: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>> data =
                  snapshot.data as QuerySnapshot<Map<String, dynamic>>;

              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  data.docs;

              return ListView.builder(
                itemCount: allDocs.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 250,
                      child: Card(
                        // color: Colors.red,
                        color: Colors
                            .accents[Random().nextInt(Colors.accents.length)],
                        elevation: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "${allDocs[i].data()['title']}",
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${allDocs[i].data()['body']}",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Update Notes"),
                                        content: SizedBox(
                                          height: 300,
                                          width: 250,
                                          child: Form(
                                            key: updateKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  validator: (val) => (val!
                                                          .isEmpty)
                                                      ? "Enter title First..."
                                                      : null,
                                                  onSaved: (val) {
                                                    title = val;
                                                  },
                                                  controller:
                                                      titleUpDateController,
                                                  decoration: const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText:
                                                          "Enter title Here....",
                                                      labelText: "title"),
                                                ),
                                                const SizedBox(height: 10),
                                                TextFormField(
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  maxLines: 5,
                                                  validator: (val) => (val!
                                                          .isEmpty)
                                                      ? "Enter body First..."
                                                      : null,
                                                  onSaved: (val) {
                                                    body = val;
                                                  },
                                                  controller:
                                                      bodyUpDateController,
                                                  decoration: const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText:
                                                          "Enter body Here....",
                                                      labelText: "body"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (updateKey.currentState!
                                                  .validate()) {
                                                updateKey.currentState!.save();
                                              }

                                              Map<String, dynamic> recode = {
                                                "title": title,
                                                "body": body,
                                              };

                                              await FirebaseDBHelpers
                                                  .firebaseDBHelpers
                                                  .updateNote(
                                                      data: recode,
                                                      id: allDocs[i].id);

                                              Navigator.of(context).pop();

                                              setState(() {
                                                titleUpDateController.clear();
                                                bodyUpDateController.clear();

                                                title = null;
                                                body = null;
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Notes update successfully...",
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: const Text("update"),
                                          ),
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  onPressed: () {
                                    FirebaseDBHelpers.firebaseDBHelpers
                                        .deleteNote(id: allDocs[i].id);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Add"),
        icon: const Icon(Icons.add),
        onPressed: () async {
          validete(context);
        },
      ),
    );
  }

  validete(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Notes"),
            content: SizedBox(
              height: 300,
              width: 250,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Enter The title...";
                          }
                          return null;
                        },
                        onSaved: (val) {
                          title = val;
                        },
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: "Enter The title...",
                          label: Text("title"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Enter The body...";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        maxLines: 5,
                        onSaved: (val) {
                          body = val;
                        },
                        controller: bodyController,
                        decoration: const InputDecoration(
                          hintText: "Enter The body...",
                          label: Text("body"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                  }

                  Map<String, dynamic> recode = {
                    "title": title,
                    "body": body,
                  };

                  await FirebaseDBHelpers.firebaseDBHelpers
                      .insertNote(data: recode);

                  setState(() {
                    Navigator.pop(context);

                    titleController.clear();
                    bodyController.clear();

                    title = null;
                    body = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Recode inserted successfully..."),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Insert"),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ],
          );
        });
  }
}
