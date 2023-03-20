import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _userEnterMessage = '';

  void _sendMessage() async{
    FocusScope.of(context).unfocus(); //키보드 사라짐
    final user= FirebaseAuth.instance.currentUser;
    final userData =  await FirebaseFirestore.instance.collection('user').doc(user!.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': _userEnterMessage,
      'time': Timestamp.now(),
      'userID': user!.uid,
      'userName' : userData.data()!['userName'],
      'userImage' : userData['picked_image'],
    });
    _controller.clear(); //메세지 사라짐
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: null, //줄바꿈
              controller: _controller,
              decoration: InputDecoration(labelText: 'send a message..'),
              onChanged: (value) {
                //텍스트필드에 값이 입력되면 Send a message 버튼을 비활성화하는 validation 기능 구현
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _userEnterMessage.trim().isEmpty
                ? null
                : _sendMessage, //없으면 버튼 비활성화, 있으면 활성화
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
