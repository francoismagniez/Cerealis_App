import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gallery_saver/gallery_saver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ArCoreController.checkArCoreAvailability();
  await ArCoreController.checkIsArCoreInstalled();
  runApp(AugmentedPage());
}

class AugmentedPage extends StatefulWidget {
  @override
  _AugmentedPageState createState() => _AugmentedPageState();
}

class _AugmentedPageState extends State<AugmentedPage> {
  ArCoreController? arCoreController;
  Map<int, ArCoreAugmentedImage> augmentedImagesMap = Map();
  ScreenshotController screenshotController = ScreenshotController();
  bool isCaptureMessageVisible = false;
  double _opacity = 0.0;

  _captureAndSaveImage() async {
    try {
      // Demande de permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (status.isGranted) {
        final capturedImage = await screenshotController.capture();

        final externalDir = await getExternalStorageDirectory();
        final imagePath = '${externalDir!.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);

        await imageFile.writeAsBytes(capturedImage!);
        print("Image saved at $imagePath");

        // Inform the gallery about the new picture
        await GallerySaver.saveImage(imagePath);

        setState(() {
          isCaptureMessageVisible = true;
          _opacity = 1.0;  // Modifie l'opacité pour commencer le fade-in
        });

        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _opacity = 0.0;  // Modifie l'opacité pour commencer le fade-out
          });
        }).then((_) => Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isCaptureMessageVisible = false;  // Cache le message après le fade-out
          });
        }));
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Screenshot(
        controller: screenshotController,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF5d6bb2),
            title: Text('Observe tes animaux préférés !'),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ArCoreView(
                    onArCoreViewCreated: _onArCoreViewCreated,
                    type: ArCoreViewType.AUGMENTEDIMAGES,
                  ),
                ),
              ),
              if (isCaptureMessageVisible)
                Positioned.fill(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: Duration(seconds: 1),
                      opacity: _opacity,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF5d6bb2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'La capture d\'écran a bien été effectuée',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                right: 16, // changé de "left" à "right"
                child: FloatingActionButton(
                  onPressed: _captureAndSaveImage,
                  tooltip: 'Capture Image',
                  child: Icon(Icons.camera_alt), // changé l'icône pour représenter un appareil photo
                  backgroundColor: Color(0xFF5d6bb2), // ajouté pour correspondre à la couleur de l'autre bouton
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Image.asset(
                  'assets/others/cerealis.png',
                  width: 100,
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: Color(0xFF5d6bb2),
                  onPressed: () {},
                  tooltip: 'Interaction',
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController?.onTrackingImage = _handleOnTrackingImage;
    loadImagesDatabase();
  }

  loadImagesDatabase() async {
    final ByteData bytes = await rootBundle.load('assets/myimages.imgdb');
    arCoreController?.loadAugmentedImagesDatabase(bytes: bytes.buffer.asUint8List());
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    if (!augmentedImagesMap.containsKey(augmentedImage.index)) {
      augmentedImagesMap[augmentedImage.index] = augmentedImage;
      if (augmentedImage.name == "snake.png") {
        _addSnake(augmentedImage);
      } else if (augmentedImage.name == "monkey.png") {
        _addMonkey(augmentedImage);
      }
    }
  }

  void _addMonkey(ArCoreAugmentedImage augmentedImage) {
    final node = ArCoreReferenceNode(
        name: 'Monkey',
        object3DFileName: 'Monkey.sfb',
        position: vector.Vector3(0, 0, 0),
        scale: vector.Vector3(0.1, 0.1, 0.1));
    arCoreController?.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  void _addSnake(ArCoreAugmentedImage augmentedImage) {
    final node = ArCoreReferenceNode(
        name: 'SnakeCentered',
        object3DFileName: 'SnakeCentered.sfb',
        position: vector.Vector3(0, 0, 0),
        scale: vector.Vector3(0.1, 0.1, 0.1));
    arCoreController?.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}
