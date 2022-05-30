import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Constants/constants.dart';

class Message extends StatefulWidget {
  const Message({Key? key}) : super(key: key);

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  late final dref = FirebaseDatabase.instance.reference();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  var collection = FirebaseFirestore.instance.collection('library');
  late DatabaseReference databaseReference;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Announcements ',
          style: TextStyle(
            color: PrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_sharp,
            color: PrimaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Center(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('sentbox')
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.hasError)
                      return Text('Error = ${snapshot.error}');

                    if (snapshot.hasData) {
                      final docs = snapshot.data!.docs;
                      return SingleChildScrollView(
                        child: Container(
                          height: size.height * 1,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: docs.length,
                            itemBuilder: (_, i) {
                              final data = docs[i].data();
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 3),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Container(

                                          child: Container(
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              alignment: Alignment.centerLeft,
                                              image: NetworkImage(
                                                "https://upload.wikimedia.org/wikipedia/en/thumb/1/1d/Sri_Lanka_Police_logo.svg/1200px-Sri_Lanka_Police_logo.svg.png",

                                              ),),
                                          color: Colors.grey,
                                          gradient: LinearGradient(
                                              colors: [
                                                gradientStart,
                                                gradientEnd
                                              ],
                                              begin: FractionalOffset(0.5, 0),
                                              end: FractionalOffset(0, 0.5),
                                              stops: [0.0, 1.0],
                                              tileMode: TileMode.clamp),
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              topLeft: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(10)),
                                        ),
                                        height: 80,
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(data['message'],style: TextStyle(fontSize: 20),),
                                              Text("From Police Department",style: TextStyle(color: lightGray),),
                                            ],
                                          ),
                                        ),
                                      ),

                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }

                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
