import 'package:arts/ui/settings.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'editprofilescreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({Key? key}) : super(key: key);

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Partner"),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded))
          ],
        ),
        body: Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text("Partner", style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: AppLocalizations.of(context)!.modifyPassword,
                    child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfileScreen()),
                          );
                        },
                        icon: const Icon(size: 30, Icons.edit)),

                  )
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: AppLocalizations.of(context)!.settings,
                    child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
                          );
                        },
                        icon: const Icon(size: 30, Icons.settings)),
                  ),
                ],
              ),

              const SizedBox(height: 200),

              FloatingActionButton.large(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraQRScreen()),
                  );
                },
                elevation: 5.0,
                backgroundColor: Theme.of(context).iconTheme.color,
                child: const Icon(Icons.qr_code_2_outlined, size: 60),
              ),
            ]
        )
    );
  }
}

class CameraQRScreen extends StatefulWidget {
  const CameraQRScreen({Key? key}) : super(key: key);

  @override
  State<CameraQRScreen> createState() => _CameraQRScreenState();
}

class _CameraQRScreenState extends State<CameraQRScreen> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.frameQR),
          actions: [
            IconButton(
              color: Theme.of(context).iconTheme.color,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return Icon(Icons.flash_off, color: Theme.of(context).iconTheme.color);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return Icon(Icons.camera_front, color:Theme.of(context).iconTheme.color);
                    case CameraFacing.back:
                      return Icon(Icons.camera_rear, color:Theme.of(context).iconTheme.color);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) {
              if (barcode.rawValue == null) {
                debugPrint('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue!;
                debugPrint('Barcode found! $code');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FoundedQR(code: code)),
                );
              }
            })
    );
  }
}

class FoundedQR extends StatefulWidget {
  const FoundedQR({Key? key, required this.code}) : super(key: key);
  final String code;

  @override
  State<FoundedQR> createState() => _FoundedQRState();
}

class _FoundedQRState extends State<FoundedQR> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center (
          child: Text(widget.code),
        )
    );
  }
}