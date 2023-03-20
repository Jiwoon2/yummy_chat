import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yummy_chat/add_image/add_image.dart';
import 'package:yummy_chat/config/palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummy_chat/screens/chat_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _authentication = FirebaseAuth.instance; //사용자의 등록, 인증에 사용

  bool isSignupScreen = true; //로그인, 사인업 구별 변수
  bool showSpinner = false; //전송 버튼을 누르면 스피너가 돎

  //바인드할 state는 폼 위젯을 통해 모든 textForm필드에 validation을 작동시킬 것이므로 <FormState>
  final _formKey = GlobalKey<FormState>();

  //TextFormField의 onSaved 메소드에서 value값이 전달될때마다 업데이트 됨
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  File? userPickedImage;

  void pickedImage(File image) {
    userPickedImage = image;
  }

  void _tryValidation() {
    //사용자가 텍스트 폼필드에 입력한 정보의 유효성 확인
    final isValid =
        _formKey.currentState!.validate(); //폼필드 validator을 작동시킬 수 있음
    if (isValid) {
      _formKey.currentState!.save(); //유효하면 폼전체의 state 값을 저장
    }
  }

  //사진 등록 팝업창
  void showAlert(BuildContext context) {
    //팝업창이므로 호출되면 위젯트리에 삽입돼야함
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: AddImage(
              pickedImage), //메서드를 실행시키는것이 아니라 메서드의 위치를 가리키고 있는 포인터만을 전달 = 메서드의 위치 저장
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus(); //textfield에서 화면 아무곳 누르면 키보드 사라지게 하기
          },
          child: Stack(
            children: [
              //배경
              Positioned(
                //컨테이너의 위치를 스크린 상단의 시작점에 맞추기 위해 왼,오 0으로 지정
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('image/red.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 90, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Welcome',
                            style: TextStyle(
                              letterSpacing: 1.0,
                              fontSize: 25,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    isSignupScreen ? ' to Yummy chat' : ' back',
                                style: TextStyle(
                                  letterSpacing: 1.0,
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          isSignupScreen
                              ? 'Signup to continue'
                              : 'Signin to continue',
                          style: TextStyle(
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //텍스트 폼 필드
              AnimatedPositioned(
                top: 180,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  padding: EdgeInsets.all(20.0),
                  height: isSignupScreen ? 280.0 : 250.0,
                  //왜 이거에 따라 높이가 달라질까-> 첫 Positioned에서 위치를 정해서 그런듯
                  width: MediaQuery.of(context).size.width - 40,
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Row(
                          //로그인, 사인업 버튼 배치를 위해 row
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = false;
                                });
                              },
                              child: Column(
                                //로그인, 사인업 밑줄을 위해 column
                                children: [
                                  Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          !isSignupScreen //signup이 선택되지 않았을때 => 로그인 화면이 선택되었을때
                                              ? Palette.activeColor
                                              : Palette.textColor1,
                                    ),
                                  ),
                                  if (!isSignupScreen) //signup이 선택되지 않았을때만 밑줄을 그림
                                    Container(
                                      margin: EdgeInsets.only(top: 3),
                                      height: 2,
                                      width: 55,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = true;
                                });
                              },
                              child: Column(
                                //로그인, 사인업 밑줄을 위해 column
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'SIGNUP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSignupScreen
                                              ? Palette.activeColor
                                              : Palette.textColor1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      if (isSignupScreen)
                                        GestureDetector(
                                          onTap: () {
                                            showAlert(context);
                                          },
                                          child: Icon(
                                            Icons.image,
                                            color: isSignupScreen
                                                ? Colors.cyan
                                                : Colors.grey[300],
                                          ),
                                        )
                                    ],
                                  ),
                                  if (isSignupScreen)
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 3, 35, 0),
                                      height: 2,
                                      width: 55,
                                      color: Colors.orange,
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSignupScreen) //signup 스크린을 위한 텍스트 폼필드를 담고 있는 컨테이너
                          Container(
                            margin: EdgeInsets.only(
                              top: 20,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: ValueKey(1),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 4) {
                                        return 'Please enter at least 4 characters';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      //값 저장
                                      userName = value!;
                                    },
                                    onChanged: (value) {
                                      //파이어베이스 인증을 위해 사용자가 텍스트 폼필드에 입력하는 값을 저장해 가져옴
                                      userName = value;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Palette.iconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          //테두리
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          //텍스트 필드를 선택해도 테두리가 보여지도록 함
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'User name',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textColor1,
                                        ),
                                        contentPadding:
                                            EdgeInsets.all(10) //텍스트 입력 창 폭 줄임
                                        ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    //이메일용 키보드
                                    key: ValueKey(2),
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Palette.iconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          //테두리
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          //텍스트 필드를 선택해도 테두리가 보여지도록 함
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'email',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textColor1,
                                        ),
                                        contentPadding:
                                            EdgeInsets.all(10) //텍스트 입력 창 폭 줄임
                                        ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    //숨기기
                                    key: ValueKey(3),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return 'Password must be at least 7 characters long.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Palette.iconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          //테두리
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          //텍스트 필드를 선택해도 테두리가 보여지도록 함
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'password',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textColor1,
                                        ),
                                        contentPadding:
                                            EdgeInsets.all(10) //텍스트 입력 창 폭 줄임
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!isSignupScreen) //login 스크린을 위한 텍스트 폼필드를 담고 있는 컨테이너
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: ValueKey(4),
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Palette.iconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          //테두리
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          //텍스트 필드를 선택해도 테두리가 보여지도록 함
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'email',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textColor1,
                                        ),
                                        contentPadding:
                                            EdgeInsets.all(10) //텍스트 입력 창 폭 줄임
                                        ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  TextFormField(
                                    key: ValueKey(5),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return 'Password must be at least 7 characters long.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Palette.iconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          //테두리
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          //텍스트 필드를 선택해도 테두리가 보여지도록 함
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'password',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Palette.textColor1,
                                        ),
                                        contentPadding:
                                            EdgeInsets.all(10) //텍스트 입력 창 폭 줄임
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              //전송버튼
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: isSignupScreen ? 430 : 390,
                right: 0,
                left: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        //signup 기능
                        if (isSignupScreen) {
                          if (userPickedImage == null) {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please pick your image'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                            return;
                          }
                          _tryValidation(); //유효성 체크 함수
                          try {
                            //새 유저 등록
                            final newUser = await _authentication
                                .createUserWithEmailAndPassword(
                              email: userEmail,
                              password: userPassword,
                            );

                            //스토리지에 등록
                            final refImage= FirebaseStorage.instance
                                .ref()
                                .child('picked_image')
                                .child(newUser.user!.uid + '.png');

                            await refImage.putFile(userPickedImage!);
                            final url= await refImage.getDownloadURL(); //스토리지에 저장된 이미지 url을 할당
                            
                            //새로운 유저 등록 완료하면 컬렉션에 저장하기
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(newUser.user!.uid)
                                .set({
                              //데이터는 Map 형태
                              'userName': userName,
                              'email': userEmail,
                              'picked_image': url,
                            });

                            if (newUser.user != null) {
                              //null이 아니면 등록 성공
                              // Navigator.push( //main.dart에서 스트림으로 이동시켰기 때문에 불필요
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ChatScreen(),
                              //   ),
                              // );
                              setState(() {
                                showSpinner = false; //스피너 멈춤
                              });
                            }
                          } catch (e) {
                            print(e);
                            if (mounted) {
                              //위젯이 사라지는 순간 false가 됨
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Please check your email or password'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          }
                        }
                        //login 기능
                        if (!isSignupScreen) {
                          _tryValidation();
                          try {
                            final newUser = await _authentication
                                .signInWithEmailAndPassword(
                              email: userEmail,
                              password: userPassword,
                            );
                            if (newUser.user != null) {
                              //null이 아니면 등록 성공
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange,
                              Colors.red,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              //구글 로그인 버튼
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: isSignupScreen
                    ? MediaQuery.of(context).size.height - 125
                    : MediaQuery.of(context).size.height - 165,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    Text(isSignupScreen ? 'or Signup with' : 'or Signin with'),
                    SizedBox(
                      height: 10,
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: Size(155, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Palette.googleColor,
                      ),
                      icon: Icon(Icons.add),
                      label: Text('Google'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
