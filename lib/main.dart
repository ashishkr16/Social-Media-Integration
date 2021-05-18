import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/cupertino.dart';

GoogleSignIn _googleSignIn = GoogleSignIn();

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GoogleSignInAccount? _currentUser;
  bool _isLoggedIn = false;
  Map<String, dynamic> _userObj = {};

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleSignIn();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(_currentUser!.photoUrl ?? ''))),
          ),
          Padding(padding: EdgeInsets.only(top: 15)),
          Text(
            user.displayName ?? '',
            style: TextStyle(fontSize: 22),
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          Text(
            user.email,
            style: TextStyle(fontSize: 18),
          ),
          Padding(padding: EdgeInsets.only(top: 25)),
          const Text(
            "Signed in successfully.",
            style: TextStyle(fontSize: 18),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          CupertinoButton(
            color: Colors.blue,
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
        ],
      );
    }
    if (_isLoggedIn == true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(_userObj["picture"]["data"]["url"]))),
          ),
          Text(
            _userObj["name"],
            style: TextStyle(fontSize: 30),
          ),
          Text(
            _userObj["email"],
            style: TextStyle(fontSize: 20),
          ),
          Padding(
              padding: EdgeInsets.only(top: 25),
              child: CupertinoButton(
                  color: Colors.blue,
                  onPressed: () {
                    FacebookAuth.instance.logOut().then((value) => {
                          setState(() {
                            _isLoggedIn = false;
                            _userObj = {};
                          })
                        });
                  },
                  child: Text("Logout"))),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 70),
            child: const Text(
              "You are not currently signed in.",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: GoogleAuthButton(
              onPressed: _handleSignIn,
              darkMode: false,
              style: AuthButtonStyle(
                iconType: AuthIconType.secondary,
                buttonColor: Colors.transparent,
              ), // if true second example
            ),
          ),
          FacebookAuthButton(
            onPressed: () async {
              FacebookAuth.instance.login(permissions: [
                "public_profile",
                "email"
              ]).then((value) => {
                    FacebookAuth.instance.getUserData().then((userData) {
                      setState(() {
                        _isLoggedIn = true;
                        _userObj = userData;
                      });
                    })
                  });
            },
            darkMode: false,
            style: AuthButtonStyle(
              iconType: AuthIconType.outlined,
              buttonColor: Colors.lightBlueAccent,
            ), // if true second example
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media Integration'),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}
