import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seam/services/authentication.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  bool _passwordshow;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 &&
            userId != null &&
            _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else {
            if (e && e.code == 'ERROR_INVALID_EMAIL') {
              _errorMessage = 'Formato de correo electrónico invalido.';
            } else if (e && e.code == 'ERROR_WRONG_PASSWORD') {
              _errorMessage = 'Contraseña incorrecta.';
            } else {
              _errorMessage = e.message;
            }
          }
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _passwordshow = false;
    super.initState();
  }

/*
  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }
*/
  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Theme.of(context).primaryColor,
        // appBar: new AppBar(
        //   title: new Text('Flutter login'),
        // ),
        // backgroundColor: Color.fromRGBO(21, 19, 18, 1),
        body: Stack(
          children: <Widget>[
            _showBody(),
            // _showCircularProgress(),
          ],
        ));
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verifica tu cuenta."),
          // backgroundColor: Color.fromRGBO(21, 19, 18, 1),
          titleTextStyle: TextStyle(color: Colors.white),
          content:
              new Text("Se ha enviado un link de confirmacion a su correo."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cerrar"),
              color: Colors.white,
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody() {
    return new Column(
      // shrinkWrap: true,
      children: <Widget>[
        Container(
            height: 350,
            child: Column(
              children: <Widget>[
                _showLogo(),
                _showText(),
              ],
            )),
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0))),
          child: _isLoading
              ? Center(
                  child: SizedBox(
                      height: 200.0,
                      width: 200.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 8.0,
                        valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor),
                      )))
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _showEmailInput(),
                      _showPasswordInput(),
                      _showErrorMessage(),
                      _showPrimaryButton(),
                      // _showSecondaryButton(),
                    ],
                  ),
                ),
        )),
      ],
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 16.0,
            color: Theme.of(context).primaryColor,
            height: 1.0,
            fontWeight: FontWeight.w700),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Padding(
        padding: EdgeInsets.only(top: 90.0, bottom: 60.0),
        child: new Image(
          image: AssetImage('assets/images/logo_white.png'),
          height: 80,
        ));
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Text(
        'EMERGENCIA MUNICIPAL',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 22),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _email = value.trim(),
          decoration: InputDecoration(
              prefixIcon: Icon(
                FontAwesomeIcons.envelope,
                size: 18.0,
              ),
              labelText: 'Correo Electrónico'),
        )
        // new BeautyTextfield(
        //   height: 50,
        //   width: double.maxFinite,
        //   maxLines: 1,
        //   autocorrect: true,
        //   autofocus: false,
        //   backgroundColor: Theme.of(context).primaryColor,
        //   accentColor: Colors.white,
        //   textColor: Colors.black87,
        //   wordSpacing: 1,
        //   cornerRadius: BorderRadius.circular(10),
        //   prefixIcon: new Icon(Icons.mail_outline),
        //   placeholder: 'Correo',
        //   inputType: TextInputType.emailAddress,
        //   onChanged: (value) => _email = value.trim(),
        //   // validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        //   // onSaved: (value) => _email = value.trim(),
        // ),
        );
  }

  Widget _showPasswordInput() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Stack(alignment: Alignment.centerRight, children: <Widget>[
          TextField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: !_passwordshow,
              onChanged: (value) => _password = value.trim(),
              decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(FontAwesomeIcons.key, size: 18.0))),
          IconButton(
              onPressed: () {
                setState(() {
                  _passwordshow = !_passwordshow;
                });
              },
              icon: Icon(
                _passwordshow
                    ? FontAwesomeIcons.eyeSlash
                    : FontAwesomeIcons.eye,
                size: 18.0,
                color: Colors.black54,
              )),
        ])
        // child: new BeautyTextfield(
        //   maxLines: 1,
        //   obscureText: true,
        //   autofocus: false,
        //   height: 50,
        //   backgroundColor: Theme.of(context).primaryColor,
        //   accentColor: Colors.white,
        //   textColor: Colors.black54,
        //   cornerRadius: BorderRadius.circular(10),
        //   inputType: TextInputType.visiblePassword,
        //   width: double.maxFinite,
        //   prefixIcon: new Icon(Icons.lock_outline),
        //   placeholder: 'Contraseña',
        //   onChanged: (value) => _password = value.trim(),
        // ),
        );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
        child: SizedBox(
          height: 50.0,
          width: double.infinity,
          child: new FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            color: Theme.of(context).primaryColor,
            child: _formMode == FormMode.LOGIN
                ? new Text('Iniciar Sesión',
                    style: new TextStyle(fontSize: 18.0, color: Colors.white))
                : new Text('Crear Cuenta',
                    style: new TextStyle(fontSize: 18.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}
