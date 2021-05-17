import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
          GoogleUserCircleAvatar(
            identity: user,
          ),
          Text(user.displayName ?? ''),
          Text(user.email),
          const Text("Signed in successfully."),
          ElevatedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
        ],
      );
    }
    if (_isLoggedIn == true) {
      return Column(
        children: [
          Image.network(_userObj["picture"]["data"]["url"]),
          Text(_userObj["name"]),
          Text(_userObj["email"]),
          ElevatedButton(
              onPressed: () {
                FacebookAuth.instance.logOut().then((value) => {
                      setState(() {
                        _isLoggedIn = false;
                        _userObj = {};
                      })
                    });
              },
              child: Text("Logout"))
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN WITH GOOGLE'),
            onPressed: _handleSignIn,
          ),
          ElevatedButton(
            child: const Text('SIGN IN WITH FACEBOOK'),
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
