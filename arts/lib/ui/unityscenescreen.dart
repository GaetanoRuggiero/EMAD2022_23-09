import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class UnitySceneScreen extends StatefulWidget {
  final String poiName;
  final String modelName;

  const UnitySceneScreen({Key? key, required this.poiName, required this.modelName}) : super(key: key);

  @override
  State<UnitySceneScreen> createState() => _UnitySceneScreenState();
}

class _UnitySceneScreenState extends State<UnitySceneScreen> {

  late UnityWidgetController _unityWidgetController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unityWidgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          UnityWidget(
            onUnityCreated: _onUnityCreated,
            onUnityMessage: onUnityMessage,
            fullscreen: true
          ),
          PointerInterceptor(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                double velocity = details.delta.dx * 13;
                double sensitivity = 20;
                double threshold = 500;
                if (velocity > threshold) {
                  // Maximum Right Swipe
                  velocity = threshold;
                }
                else if (velocity < -threshold) {
                  velocity = -threshold;
                }
                else if (velocity > sensitivity ||  velocity < -sensitivity) {
                  setRotationSpeed(velocity.toString());
                }
                else {
                  velocity = 0; // User is swiping very slowly
                  setRotationSpeed(velocity.toString());
                }

              },
            )
          ),
        ],
      ),
    );
  }

  void setRotationSpeed(String speed) {
    _unityWidgetController.postMessage(
      widget.modelName,
      'SetRotationSpeed',
      speed,
    );
  }

  void instantiateModel(String modelName) {
    _unityWidgetController.postMessage(
      'POI',
      'InstantiateModel',
      modelName,
    );
  }

  void onUnityMessage(message) {
    debugPrint('Received message from unity: ${message.toString()}');
  }

  // Callback that connects the created controller to the unity controller
  void _onUnityCreated(controller) {
    controller.resume();
    _unityWidgetController = controller;
    instantiateModel(widget.modelName);
  }
}
