import 'package:flutter/material.dart';
import 'package:mini_quiz_creator/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String _errorText = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(builder: (context, setState) {
              _handleSubmit() async {
                if (_formKey.currentState!.validate()) {
                  try {
                    setState(() {
                      _errorText = '';
                      _loading = true;
                    });
                    final response = await supabase.auth.verifyOTP(
                        token: _otpController.text,
                        type: OtpType.magiclink,
                        email: ModalRoute.of(context)!.settings.arguments
                            as String);
                    Navigator.pushNamed(context, '/');
                  } on AuthException catch (e) {
                    setState(() {
                      _errorText = e.message.toString();
                    });
                    _formKey.currentState!.validate();
                  } finally {
                    setState(() {
                      _loading = false;
                    });
                  }
                }
              }

              return Form(
                key: _formKey,
                child: TextFormField(
                  controller: _otpController,
                  onFieldSubmitted: (value) {
                    _handleSubmit();
                  },
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    errorText: _errorText,
                    prefixIcon: Icon(Icons.password),
                    suffixIcon: IconButton(
                      icon: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(Icons.login),
                      onPressed: _handleSubmit,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'OTP is required';
                    } else if (value.length != 6 ||
                        int.tryParse(value) == null) {
                      return 'Please enter a valid 6-digit OTP';
                    }
                    return null;
                  },
                ),
              );
            }),
          ],
        ),
      )),
    );
  }
}
