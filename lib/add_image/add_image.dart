import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  const AddImage(this.addImageFunc, {Key? key}) : super(key: key);

  final Function(File pickedImage) addImageFunc; //함수도 다른 메서드에 인자값으로 전달될 수 있음

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File? pickedImage;

  void _pickerImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
      source: ImageSource.camera, //카메라로 이미지를 가져옴
      imageQuality: 50,
      maxHeight: 150,
    );
    setState(() {
      if (pickedImageFile != null) {
        pickedImage = File(pickedImageFile.path);
      }
    });

    widget.addImageFunc(pickedImage!); //이미지 전달받음
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //팝업창 크기
      padding: EdgeInsets.only(top: 10),
      width: 150,
      height: 300,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            backgroundImage:
                pickedImage != null ? FileImage(pickedImage!) : null,
          ),
          SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: _pickerImage,
            icon: Icon(Icons.image),
            label: Text('Add icon'),
          ),
          SizedBox(
            height: 80,
          ),
          //팝업창 종료
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
            label: Text('Close'),
          ),
        ],
      ),
    );
  }
}
