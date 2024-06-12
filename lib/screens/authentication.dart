import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_chat/providers/authentication_provider.dart';
import 'package:test_chat/widgets/user_image_picker.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isAuthenticating = false;
  var _enteredUsername = '';
  var _enteredSurname = '';
  String? _email;
  String? _password;
  File? _selectedImage;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (!_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please pick an image.')),
      );
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    try {
      if (_isLogin) {
        await authProvider.signIn(_email!, _password!);
      } else {
        await authProvider.signUp(
          email: _email!,
          password: _password!,
          username: _enteredUsername,
          surname: _enteredSurname,
          image: _selectedImage!,
        );
      }
    } on Exception catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  _isLogin ? 'Войти' : 'Регистрация',
                  style: const TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: _isLogin
                    ? const EdgeInsets.all(20)
                    : const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Почта'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            maxLength: 50,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _email = newValue;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Имя'),
                              ),
                              enableSuggestions: false,
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              maxLength: 10,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length <= 4) {
                                  return 'Enter a valid Name';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredUsername = newValue!;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Фамилия'),
                              ),
                              enableSuggestions: false,
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              maxLength: 10,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length <= 1) {
                                  return 'Enter a valid Surname';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredSurname = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Пароль'),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Пароль должен быть не меньше 6 знаков';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(
                                _isLogin ? 'Войти' : 'Регистрация',
                              ),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Создать аккаунт'
                                  : 'Аккаунт уже есть'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
