
import 'dart:io';
import 'dart:typed_data';
import 'package:DermaScan/cameraPreview.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image/image.dart' as img;

class Offline extends StatefulWidget {

  late List<CameraDescription> cameras;

   Offline({Key? key, required this.cameras}) : super(key: key);

  @override
  _OfflineState createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;

  var v = "";
  late CameraController controller;
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
    loadmodel().then((value) {
      setState(() {});
    });
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/rs.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File file = File(image.path);
        img.Image image2 = img.decodeImage(await file.readAsBytes())!;
        img.Image resizedImage =
        img.copyResize(image2, width: 244, height: 244);

        setState(() {
          _image = XFile(file.path);
        });

        detectimage(resizedImage);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
  Future<void> _scanPhoto() async {
    
    final image = await controller.takePicture();
  }

  Future detectimage(img.Image image) async {
    var recognitions = await Tflite.runModelOnBinary(
        binary: imageToByteListFloat32(image, 224, 0, 1),
        numResults: 2,
        threshold: 0.05, 
        asynch: true
     
    );
    setState(() {
      v = recognitions.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Detection'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              )
            else
              const Text('No image selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image from Gallery'),
            ),
            const SizedBox(height: 20),
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
                  img.Image image2 = img.decodeImage(await file2.readAsBytes())!;
                  setState(() {
                    _image = selectedImage;
                  });
                  await detectimage(image2);
                }
              },
              child: const Text('Appareil photo'),
            ),
            const SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}

Uint8List imageToByteListFloat32(
    img.Image image, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (pixel.r - mean) / std;
      buffer[pixelIndex++] = (pixel.g - mean) / std;
      buffer[pixelIndex++] = (pixel.b - mean) / std;
    }
  }
  return convertedBytes.buffer.asUint8List();
}
