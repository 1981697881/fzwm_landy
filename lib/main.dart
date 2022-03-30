import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fzwm_landy/model/login_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fzwm_landy/views/login/login_page.dart';
import 'package:fzwm_landy/views/index/index_page.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'http/httpUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fzwm_landy/utils/toast_util.dart';
import 'package:fzwm_landy/server/api.dart';
import 'package:fzwm_landy/http/api_response.dart';
import 'model/currency_entity.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
const Color _primaryColor = Colors.blue;

void main(List<String> args) async {
  HttpUtils.init(
    baseUrl: "http://192.168.31.188/K3Cloud/",
  );
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true
  );
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  //不显示 debug标签

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //不显示 debug标签
      debugShowCheckedModeBanner: false,
      //当前运行环境配置
      locale: Locale("zh","CH"),
      //程序支持的语言环境配置
      supportedLocales: [Locale("zh","CH")],
      //Material 风格代理配置
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: _primaryColor,
        // primaryTextTheme: ThemeData.dark().primaryTextTheme,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _primaryColor,
        ),
        appBarTheme: AppBarTheme(
          // appBar背景色
          // color: Colors.white,
          // 浅色背景，深色字体
          brightness: Brightness.light,
          // appBar文字主题
          // textTheme: TextTheme(
          //   headline6: TextStyle(color: Colors.black),
          // ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State {
  var _getaname = "";
  var _getpsw = "";
  var username = "";
  var password = "";

  @override
  void initState() {
    super.initState();
    int count = 0;
    const period = const Duration(seconds: 1);
    print('currentTime=' + DateTime.now().toString());
    Timer.periodic(period, (timer) {
//到时回调
      print('afterTimer=' + DateTime.now().toString());
      count++;
      if (count >= 3) {
//取消定时器，避免无限回调
        timer.cancel();
        timer = null;
        toLoing();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /**
   * 验证用户名
   */
  bool validateUserName(value) {
    // 正则匹配手机号
    /*RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');*/
    if (value == null) {
      return false;
    } else if (value.trim().length < 3 || value.trim().length > 10) {
      return false;
    }
    return true;
  }

  /**
   * 验证密码
   */
  bool validatePassWord(value) {
    if (value == null) {
      return false;
    } else if (value.trim().length < 6 || value.trim().length > 18) {
      return false;
    }
    return true;
  }

  void toLoing() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _getaname = sharedPreferences.getString('username');
    _getpsw = sharedPreferences.getString('password');
    username = sharedPreferences.getString('FStaffNumber');
    password = sharedPreferences.getString('FPwd');
    print(validateUserName(_getaname) &&
        validatePassWord(_getpsw) &&
        validateUserName(username) &&
        validatePassWord(password));
    if (validateUserName(_getaname) &&
        validatePassWord(_getpsw) &&
        validateUserName(username) &&
        validatePassWord(password)) {
      Map<String, dynamic> map = Map();
      map['username'] = _getaname;
      map['acctID'] = API.ACCT_ID;
      map['lcid'] = API.lcid;
      map['password'] = _getpsw;
      ApiResponse<LoginEntity> entity = await LoginEntity.login(map);
      print(entity.data.loginResultType);
      if (entity.data.loginResultType == 1) {
        Map<String, dynamic> userMap = Map();
        userMap['FormId'] = 'BD_Empinfo';
        userMap['FilterString'] =
            "FStaffNumber='$username' and FPwd='$password'";
        userMap['FieldKeys'] = 'FStaffNumber,FUseOrgId.FName,FForbidStatus,FAuthCode,FPDASCRK,FPDASCRKS,FPDASCLL,FPDASCLLS,FPDAXSCK,FPDAXSCKS,FPDAXSTH,FPDAXSTHS,FPDACGRK,FPDACGRKS,FPDAPD,FPDAPDS,FPDAQTRK,FPDAQTRKS,FPDAQTCK,FPDAQTCKS,FPDAGXPG,FPDAGXPGS,FPDAGXHB,FPDAGXHBS,FPDASJ,FPDAXJ,FPDAKCCX';
        Map<String, dynamic> dataMap = Map();
        dataMap['data'] = userMap;
        String UserEntity = await CurrencyEntity.polling(dataMap);
        var resUser = jsonDecode(UserEntity);
        if (resUser.length > 0) {
          if (resUser[0][2] == 'A') {
            sharedPreferences.setString('MenuPermissions', UserEntity);
            /* sharedPreferences.setString('FWorkShopNumber', resUser[0][2]);
            sharedPreferences.setString('FWorkShopName', resUser[0][3]);*/
            //  print("登录成功");
            ToastUtil.showInfo('登录成功');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return IndexPage();
                },
              ),
            );
          } else {
            ToastUtil.showInfo('改账号无登录权限');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return LoginPage();
                },
              ),
            );
          }
        }
      } else {
        ToastUtil.showInfo('登录失败，重新登录');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginPage();
            },
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/splash.png"),
                fit: BoxFit.fill)));
    /* child: Image.network("https://i.postimg.cc/nh1TyksR/12133.png"),
       child:Image.network("https://i.postimg.cc/J4rL1ZpB/splash.png"),*/
  }
}
