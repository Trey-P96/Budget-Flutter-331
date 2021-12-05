import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:budget_web/data/model/auth_body.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class LoginPage extends StatefulWidget {
  final String title;

  LoginPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  late final RiveAnimationController _animationController;
  Completer<void>? _completer;

  @override
  void initState() {
    super.initState();
    _animationController = OneShotAnimation(
      'Animation 2',
      autoplay: false,
      onStart: () => setState(() => _completer = Completer()),
      onStop: () {
        setState(() {
          _completer!.complete();
          _completer = null;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: GestureDetector(
          onLongPress: () => _completer?.complete(),
          child: Text('Login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: RiveAnimation.asset(
                    'animation_2.riv',
                    animations: [],
                    fit: BoxFit.contain,
                    controllers: [_animationController],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'WELCOME TO BUDGET-X',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  height: 300,
                  child: Material(
                    elevation: 8,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(
                          color: Theme.of(context).primaryColorDark,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextField(
                              controller: _username,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Username:',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 40),
                              child: TextField(
                                controller: _password,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Password',
                                ),
                              ),
                            ),
                            Consumer(builder: (context, ref, _) {
                              return ElevatedButton(
                                child: Text('Log In'),
                                onPressed: _completer != null
                                    ? null
                                    : () async {
                                        _animationController.isActive = true;
                                        final response = await MyApp.api.login(AuthBody(
                                          username: _username.text,
                                          password: _password.text,
                                        ));

                                        print('Code ${response.statusCode}');
                                        if (response.statusCode != 200) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Unable to login: ${response.error}'),
                                            ),
                                          );
                                          await _completer!.future;
                                        } else {
                                          MyApp.dataStore.account = response.body!;
                                          await _completer!.future;

                                          Beamer.of(context).beamToNamed(
                                            Routes.home,
                                            beamBackOnPop: false,
                                          );
                                        }
                                      },
                              );
                            }),
                            SizedBox(
                              height: 32,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 1,
                                      child: ColoredBox(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2),
                                    child: Text('or'),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 1,
                                      child: ColoredBox(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                textStyle: TextStyle(fontSize: 14),
                              ),
                              onPressed: () async {
                                Beamer.of(context).beamToNamed(
                                  Routes.signUp,
                                  stacked: true,
                                );
                              },
                              child: Text('Sign up', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayOneShotAnimation extends StatefulWidget {
  const PlayOneShotAnimation({Key? key}) : super(key: key);

  @override
  _PlayOneShotAnimationState createState() => _PlayOneShotAnimationState();
}

class _PlayOneShotAnimationState extends State<PlayOneShotAnimation> {
  /// Controller for playback
  late RiveAnimationController _controller;

  /// Is the animation currently playing?
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = OneShotAnimation(
      'Animation 2',
      autoplay: false,
      onStop: () => setState(() => _isPlaying = false),
      onStart: () => setState(() => _isPlaying = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Shot Example'),
      ),
      body: Center(
        child: RiveAnimation.asset(
          'assets/loading_F.riv',
          animations: const [],
          controllers: [_controller],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // disable the button while playing the animation
        onPressed: () => _isPlaying ? null : _controller.isActive = true,
        tooltip: 'Play',
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
}
