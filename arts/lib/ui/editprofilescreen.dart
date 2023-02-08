import 'package:arts/api/user_api.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../exception/exceptions.dart';
import '../utils/user_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordOldVisible = false, isPasswordNewVisible = false, isConfirmPasswordVisible = false;
  final TextEditingController
      _controllerOldPass = TextEditingController(),
      _controllerNewPass = TextEditingController(),
      _controllerPassVal = TextEditingController();
  String errorPassword = "";
  late String _snackBarMessage;
  late Color _colorSnackbar;

  @override
  Widget build(BuildContext context) {
    double mobilesHeight = MediaQuery.of(context).size.height;
    double mobilesWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded))
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: mobilesWidth/3 > 125 ? mobilesWidth/6 : mobilesWidth/9 ,horizontal: mobilesHeight/30),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                          textAlign: TextAlign.center,
                          AppLocalizations.of(context)!.modifyPassword,
                          style: TextStyle(
                              fontSize: mobilesWidth/3 > 125 ? 40 : 25,
                              fontWeight: FontWeight.bold,
                              )
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30, top: mobilesWidth/3 > 125 ? mobilesWidth/6 : mobilesWidth/9),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controllerOldPass,
                              obscureText: isPasswordOldVisible ? false : true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPasswordOldVisible = !isPasswordOldVisible;
                                    });
                                  },
                                  child: Icon(
                                    isPasswordOldVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off
                                  ),
                                ),
                                labelText: AppLocalizations.of(context)!.oldPassword,),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .mandatoryField;
                                } else if (!UserUtils.validatePass(value)) {
                                  return AppLocalizations.of(context)!
                                      .formatPass;
                                } else {
                                  return null;
                                }
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controllerNewPass,
                              obscureText: isPasswordNewVisible ? false : true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPasswordNewVisible = !isPasswordNewVisible;
                                    });
                                  },
                                  child: Icon(
                                    isPasswordNewVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                labelText: AppLocalizations.of(context)!.newPassword,),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .mandatoryField;
                                } else if (!UserUtils.validatePass(value)) {
                                  return AppLocalizations.of(context)!
                                      .formatPass;
                                } else if (_controllerOldPass.text == value) {
                                  return AppLocalizations.of(context)!
                                      .changePasswordVerification;
                                } else {
                                  return null;
                                }
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controllerPassVal,
                              obscureText:
                              isConfirmPasswordVisible ? false : true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
                                    });
                                  },
                                  child: Icon(
                                    isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                labelText: AppLocalizations.of(context)!.passConf,),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .mandatoryField;
                                } else if (_controllerNewPass.text != value) {
                                  setState(() {
                                    errorPassword = AppLocalizations.of(context)!
                                        .noMatchingPass;
                                  });
                                  return errorPassword;
                                } else {
                                  setState(() {
                                    errorPassword = "";
                                  });
                                }
                                return null;
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            String? email = await UserUtils.readEmail();
                            String? token = await UserUtils.readToken();
                            bool changedPassword = await changePassword(email!, _controllerOldPass.text, _controllerNewPass.text, token!);
                            if (!changedPassword) {
                              setState(() {
                                _snackBarMessage = AppLocalizations.of(context)!.changedPasswordFailed;
                                _colorSnackbar = Theme.of(context).colorScheme.error;
                              });
                            } else {
                              setState(() {
                                _snackBarMessage = AppLocalizations.of(context)!.changedPasswordSucc;
                                _colorSnackbar = Theme.of(context).colorScheme.secondary;
                              });
                              if (!mounted) return;
                              Navigator.pop(context);
                            }
                            if (!mounted) return;
                            showSnackBar(context, _colorSnackbar, _snackBarMessage);
                          } on ConnectionErrorException catch(e) {
                            debugPrint(e.cause);
                            setState(() {
                              _colorSnackbar = Theme.of(context).colorScheme.error;
                            });
                            showSnackBar(context, _colorSnackbar, AppLocalizations.of(context)!.connectionError);
                          }
                        }
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.black12.withOpacity(.2),
                                  offset: const Offset(2, 2))
                            ],
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                                colors: [lightOrange, darkOrange])),
                        child: Text(AppLocalizations.of(context)!.modifyPassword,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.8),
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
