import 'package:beamer/beamer.dart';
import 'package:budget_web/data/model/account_data.dart';
import 'package:budget_web/data/model/auth_body.dart';
import 'package:budget_web/data/model/user.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/routing/routes.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerWidget {
  SignUpPage({Key? key}) : super(key: key);

  final _username = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.beamBack()),
        title: Text('Create an Account'),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: 280,
              height: MediaQuery.of(context).size.height / 2,
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        padding: const EdgeInsets.only(top: 8),
                        child: TextField(
                          controller: _password,
                          obscureText: true,
                          onChanged: (x) => _formKey.currentState!.validate(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 40),
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Confirm Password',
                          ),
                          validator: (x) {
                            return x == _password.text ? null : "Passwords do not match";
                          },
                        ),
                      ),
                      ElevatedButton(
                        child: Text('Sign Up'),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final response = await MyApp.api
                              .createUser(User(username: _username.text, password: _password.text))
                              .then<Response<dynamic>>((x) async {
                            if (!x.isSuccessful) return x;

                            final usr = x.body!;
                            return await MyApp.api.login(AuthBody(
                              username: usr.username,
                              password: usr.password,
                            ));
                          });

                          if (response.isSuccessful) {
                            MyApp.dataStore.account = response.body!;
                            Beamer.of(context).beamToNamed(
                              Routes.home,
                              replaceCurrent: true,
                            );
                            return;
                          }

                          final mngr = ScaffoldMessenger.of(context);
                          mngr.showSnackBar(SnackBar(content: Text('Unable to register, username already exists')));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
