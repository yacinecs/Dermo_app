import 'package:DermaScan/offline.dart';
import 'package:DermaScan/online.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'DermaScan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
        routes: {

          '/offline': (context) => Offline(cameras: _cameras),
          '/online': (context) => Online(cameras: _cameras),
        },
      home: const Home()
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: const Text("DermoScan"),
          centerTitle: true,

        ),
            body:
                Center(
                  child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        style: ButtonStyle(fixedSize: MaterialStateProperty.all(const Size(150,0))),
                        icon:const Icon(Icons.cloud_off_rounded)
                        ,label:const Text("Offline") ,
                        onPressed: (){
                          Navigator.pushNamed(context, '/offline');
                        }
                    ),
                    const SizedBox(height: 50.0),
                    ElevatedButton.icon
                      (
                        style: ButtonStyle(fixedSize: MaterialStateProperty.all(const Size(150,0))),
                        icon:const Icon(Icons.online_prediction_rounded) ,
                        label:const Text("Online") ,
                        onPressed: (){
                          Navigator.pushNamed(context, '/online');
                        }
                    )
                  ],
                ),)

      ),
    );
  }
}


