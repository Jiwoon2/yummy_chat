import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication =
      FirebaseAuth.instance; //main_screen에서 유저 등록이 됐다면 instance로 가져올것임
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat'),
        actions: [
          //로그아웃 버튼
          IconButton(
            onPressed: () {
              _authentication.signOut();
              //Navigator.pop(context); main.dart에서 stream으로 처리함
            },
            icon: Icon(
              Icons.exit_to_app_sharp,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: StreamBuilder(
        //snapshots()으로 스트림을 전달함 -> 스트림 반환해줘서 데이터가 바뀔때마다 새로운 밸류 값을 전달해줌
        stream: FirebaseFirestore.instance
            .collection('chats/mZPSGYS2Vs5xGjPJ1HeA/message')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if(snapshot.connectionState ==ConnectionState.waiting){ //데이터를 기다려야 할 경우
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  docs[index]['text'],
                  style: TextStyle(fontSize: 20.0),
                ),
              );
            },
            itemCount: docs.length,
          );
        },
      ),
    );
  }
}
