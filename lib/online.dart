import 'dart:convert';
import 'dart:io';
import 'package:DermaScan/cameraPreview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class Online extends StatefulWidget {
  late List<CameraDescription> cameras;
  Online({Key? key, required this.cameras}): super(key: key);

  @override
  _OnlineState createState() => _OnlineState();
}

class _OnlineState extends State<Online> {
  File? _image;
  String _result = '';
  late CameraController controller;
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':

            break;
          default:

            break;
        }
      }
    });
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _result = '';
      }
    });
  }

  Future<void> _processImage() async {
    if (_image == null) {
      return;
    }

    try {
      var result = await _uploadImage(_image!.path);

      setState(() {
        _result = result;
      });
    } catch (error) {


      setState(() {
        _result = 'Error processing image';
      });
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    try {

      var ip = _ipController.text.trim();
      var uri = Uri.parse('http://$ip:5000/addplayer');

      var request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody)['value'];
      } else {

        return 'Server returned status code: ${response.statusCode}';

      }
    } catch (e) {

      if (e is SocketException) {
        return 'Network error: Check your internet connection';
      } else if (e is FormatException) {
        return 'Invalid response format from server';
      } else {
        return 'Error uploading image: $e';
      }



    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Enter IP Address',
                hintText: 'e.g., 192.168.1.34',
              ),
            ),
            const SizedBox(height: 20),
            _image == null
                ? const Text('No image selected.')
                : Image.file(
              _image!,
              height: 200,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: () async {
                final selectedImage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraPreviewWidget(controller: controller),
                  ),
                );
                if (selectedImage != null) {
                  final File file2 = File(selectedImage.path);

                  // Resize the image to 244x244
                  img.Image image2 = img.decodeImage(await file2.readAsBytes())!;
                  setState(() {
                    _image = selectedImage;
                    _result = "";
                  });
                  await _processImage();
                }
              },
              child: const Text('Appareil photo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _processImage,
              child: const Text('Process Image'),
            ),
            const SizedBox(height: 20),
            Text('Result: $_result'),
          ],
        ),
      ),
    );
  }
}