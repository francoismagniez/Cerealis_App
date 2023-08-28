import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:io';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF5d6bb2),
          title: Text('Observe tes animaux préférés !'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                  child: ArCoreView(
                    onArCoreViewCreated: _onArCoreViewCreated,
                    type: ArCoreViewType.AUGMENTEDIMAGES,
              ),
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
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController?.onTrackingImage = _handleOnTrackingImage;
    loadImagesDatabase();
  }

  loadImagesDatabase() async {
    print('loadimage');
    final ByteData bytes = await rootBundle.load('assets/myimages.imgdb');
    arCoreController?.loadAugmentedImagesDatabase(bytes: bytes.buffer.asUint8List());
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    if (!augmentedImagesMap.containsKey(augmentedImage.index)) {
      augmentedImagesMap[augmentedImage.index] = augmentedImage;

      // Vérifiez le nom de l'image détectée et ajoutez le modèle 3D correspondant
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
