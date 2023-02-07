import 'package:arts/api/user_api.dart';
import 'package:arts/ui/styles.dart';
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
  bool _showConnectionError = false;
  late String _snackBarMessage;
  late Color _colorSnackbar;

  //snackBar of Success/Error change password
  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: _colorSnackbar,
            content: Text(_snackBarMessage),
            action: SnackBarAction(
              label: 'X',
              onPressed: () {
                // Click to close
              },
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          actions: <Widget>[
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
              child: Column(
                children: [
                  Center(
                    child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Text(
                            textAlign: TextAlign.center,
                            AppLocalizations.of(context)!.modifyPassword,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.color))),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                        child: const Icon(
                          Icons.lock,
                          color: darkOrange,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 20, 10),
                            child: TextFormField(
                                controller: _controllerOldPass,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        ?.color,
                                    fontSize: 15),
                                obscureText: isPasswordOldVisible ? false : true,
                                decoration: InputDecoration(
                                  suffixIconConstraints: const BoxConstraints(
                                      minWidth: 45, maxWidth: 46),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isPasswordOldVisible = !isPasswordOldVisible;
                                      });
                                    },
                                    child: Icon(
                                      isPasswordOldVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color,
                                      size: 22,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(),
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
                                })),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                        child: const Icon(
                          Icons.lock,
                          color: darkOrange,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 20, 10),
                            child: TextFormField(
                                controller: _controllerNewPass,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        ?.color,
                                    fontSize: 15),
                                obscureText: isPasswordNewVisible ? false : true,
                                decoration: InputDecoration(
                                  suffixIconConstraints: const BoxConstraints(
                                      minWidth: 45, maxWidth: 46),
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
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color,
                                      size: 22,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(),
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
                                })),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                        child: const Icon(
                          Icons.lock,
                          color: darkOrange,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 20, 10),
                          child: TextFormField(
                              controller: _controllerPassVal,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.color,
                                  fontSize: 15),
                              obscureText:
                              isConfirmPasswordVisible ? false : true,
                              decoration: InputDecoration(
                                suffixIconConstraints: const BoxConstraints(
                                    minWidth: 45, maxWidth: 46),
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.color,
                                    size: 22,
                                  ),
                                ),
                                border: const OutlineInputBorder(),
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
                              }),
                        ),
                      ),
                    ],
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
                      _colorSnackbar = Theme.of(context).errorColor;
                    });
                  } else {
                    setState(() {
                      _snackBarMessage = AppLocalizations.of(context)!.changedPasswordSucc;
                      _colorSnackbar = Theme.of(context).colorScheme.secondary;
                    });
                    if (!mounted) return;
                    Navigator.pop(context);
                  }
                  showSnackBar();
                } on ConnectionErrorException catch(e) {
                  debugPrint(e.cause);
                  setState(() {
                    _showConnectionError = true;
                  });
                }
              }
            },
            child: Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 20),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
                  setChangedPasswordOutput(_showConnectionError),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget setChangedPasswordOutput(bool showConnectionError) {
    if (showConnectionError ) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        color: Theme.of(context).errorColor,
        child: Text(AppLocalizations.of(context)!.connectionError,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
      );
    } else {
      return Container();
    }
  }
}
