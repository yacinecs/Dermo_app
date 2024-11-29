import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CameraPreviewWidget extends StatefulWidget {
  final CameraController controller;

  const CameraPreviewWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  _CameraPreviewWidgetState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late XFile? _imageFile = null;

  Future<void> _takePicture() async {
    try {
      final image = await widget.controller.takePicture();

      setState(() {
        _imageFile = image;
      });


    } catch (e) {
      print(e);
    }
  }

  Future<void> _cropImage() async {
    if (_imageFile == null) return;

    final ImageCropper imageCropper = ImageCropper();

    File? croppedFile = await imageCropper.cropImage(
      sourcePath: _imageFile!.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepPurple,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
]
    ) as File?;




    if (croppedFile != null) {
      setState(() {
        _imageFile = XFile(croppedFile.path);
      });
    }
  }

  Future<void> _retakePicture() async {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _imageFile == null
            ? CameraPreview(widget.controller)
            : Image.file(File(_imageFile!.path)),
        Positioned(
          bottom: 20.0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _retakePicture,
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context, _imageFile);
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20.0,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: _takePicture,
                child: const Icon(Icons.camera),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
