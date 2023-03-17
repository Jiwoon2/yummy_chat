import 'package:flutter/material.dart';
import 'package:yummy_chat/screens/chat_screen.dart';
import 'package:yummy_chat/screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //파이어베이스 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatting app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:StreamBuilder(
        //authentication state가 바뀔때마다 새로운 value를 전달함
        stream: FirebaseAuth.instance.authStateChanges(),
        builder:(context,snapshot){ //인증됐으면 채팅화면
          if(snapshot.hasData){
            return ChatScreen();
          }
          return LoginSignupScreen(); //아니면 로그인화면ㅅ
        },
      ),
    );
  }
}
