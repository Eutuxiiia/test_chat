import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_chat/widgets/chat_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.user});

  final User user;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Map<String, dynamic>> list = [];
  final List<Map<String, dynamic>> searchList = [];
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          isSearching = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Чаты',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Поиск',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fillColor: const Color.fromARGB(255, 237, 242, 246),
                ),
                onChanged: (value) {
                  setState(() {
                    isSearching = value.isNotEmpty;
                    searchList.clear();

                    if (isSearching) {
                      for (var i in list) {
                        if (i['username'] != null &&
                            i['username']
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          searchList.add(i);
                        }
                      }
                    }
                  });
                },
                onTap: () {
                  setState(() {
                    isSearching = true;
                  });
                },
              ),
              const SizedBox(height: 15),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('id', isNotEqualTo: widget.user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data?.docs;
                      if (list.isEmpty) {
                        for (var i in data!) {
                          print('Data: ${i.data()}');
                          list.add(i.data() as Map<String, dynamic>);
                        }
                      }
                    }

                    return snapshot.hasData
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                isSearching ? searchList.length : list.length,
                            itemBuilder: (context, index) {
                              return ChatCard(
                                user: isSearching
                                    ? searchList[index]
                                    : list[index],
                              );
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          );
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
