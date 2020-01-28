import 'package:flutter/material.dart';
import 'package:beauty_textfield/beauty_textfield.dart';
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
          } else
            _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
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
        backgroundColor: Color.fromRGBO(211, 52, 69, 1),
        // appBar: new AppBar(
        //   title: new Text('Flutter login'),
        // ),
        // backgroundColor: Color.fromRGBO(21, 19, 18, 1),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
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
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            // shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showText(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              // _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.white,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Image(
          image: AssetImage('assets/images/logo_white.png'),
          height: 200,
        ));
  }

  Widget _showText() {
    return new Text(
      'EMERGENCIA MUNICIPAL',
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 22),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
      child: new BeautyTextfield(
        height: 50,
        width: double.maxFinite,
        maxLines: 1,
        autocorrect: true,
        autofocus: false,
        backgroundColor: Color.fromRGBO(211, 52, 69, 1),
        accentColor: Colors.white,
        textColor: Colors.black87,
        wordSpacing: 1,
        cornerRadius: BorderRadius.circular(50),
        prefixIcon: new Icon(Icons.mail_outline),
        placeholder: 'Correo',
        inputType: TextInputType.emailAddress,
        onChanged: (value) => _email = value.trim(),
        // validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        // onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new BeautyTextfield(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        height: 50,
        backgroundColor: Color.fromRGBO(211, 52, 69, 1),
        accentColor: Colors.white,
        textColor: Colors.black54,
        cornerRadius: BorderRadius.circular(50),
        inputType: TextInputType.visiblePassword,
        width: double.maxFinite,
        prefixIcon: new Icon(Icons.lock_outline),
        placeholder: 'Contraseña',
        onChanged: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 0.0),
        child: SizedBox(
          height: 50.0,
          width: double.infinity,
          child: new FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))),
            color: Colors.white,
            child: _formMode == FormMode.LOGIN
                ? new Text('Iniciar Sesion',
                    style: new TextStyle(
                        fontSize: 20.0, color: Color.fromRGBO(211, 52, 69, 1)))
                : new Text('Crear Cuenta',
                    style: new TextStyle(
                        fontSize: 20.0, color: Color.fromRGBO(211, 52, 69, 1))),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}
