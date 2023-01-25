import 'package:arts/api/user_api.dart';
import 'package:arts/exception/exceptions.dart';
import 'package:arts/ui/settings.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'editprofilescreen.dart';
import 'rewards.dart';

class ProfilePartner extends StatelessWidget {
  const ProfilePartner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profilePartner),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded))
          ],
        ),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: Text(userProvider.name, style: const TextStyle(fontSize: 20),),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Column(
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
                        ),
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
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: FloatingActionButton.large(
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
                ),
              ],
            );
          },
        ));
  }
}


class CameraQRScreen extends StatefulWidget {
  const CameraQRScreen({Key? key}) : super(key: key);

  @override
  State<CameraQRScreen> createState() => _CameraQRScreenState();
}

class _CameraQRScreenState extends State<CameraQRScreen> {


  @override
  Widget build(BuildContext context) {
    MobileScannerController cameraController = MobileScannerController();
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
          controller: cameraController,
          onDetect: (barcode, args) async {
            if (barcode.rawValue == null) {
              debugPrint('Failed to scan Barcode');
            } else {
              final String code = barcode.rawValue!;
              debugPrint('Barcode found! $code');
              bool? scanned;
              try {
                scanned = await scanQr(code);
              } on QrException catch(e) {
                debugPrint(e.cause);
                scanned = null;
              }
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return QrDialog(valid: scanned);
                },
              );

            }
          }
        )
    );
  }
}
class QrDialog extends StatelessWidget {
  const QrDialog({Key? key, required this.valid}) : super(key: key);
  final bool? valid;

  @override
  Widget build(BuildContext context) {
    String message;
    if (valid != null) {
      if (valid!) {
        message = AppLocalizations.of(context)!.qrPositiveMessage;
      } else {
        message = AppLocalizations.of(context)!.qrNegativeMessage;
      }
    } else {
      message = AppLocalizations.of(context)!.invalidQR;
    }
    return AlertDialog(
      title: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Text(AppLocalizations.of(context)!.backToHomepage)
        )
      ],
    );
  }
}