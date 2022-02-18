import 'dart:convert';
import 'package:fzwm_landy/model/currency_entity.dart';
import 'package:fzwm_landy/model/submit_entity.dart';
import 'package:fzwm_landy/utils/refresh_widget.dart';
import 'package:fzwm_landy/utils/text.dart';
import 'package:fzwm_landy/utils/toast_util.dart';
import 'package:fzwm_landy/views/login/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/more_pickers/init_data.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
import 'dart:io';
import 'package:flutter_pickers/utils/check.dart';
import 'package:flutter/cupertino.dart';
import 'package:fzwm_landy/components/my_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class RetrievalDetail extends StatefulWidget {
  RetrievalDetail({Key key}) : super(key: key);

  @override
  _RetrievalDetailState createState() => _RetrievalDetailState();
}

class _RetrievalDetailState extends State<RetrievalDetail> {
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<TextWidgetState> FBillNoKey = GlobalKey();
  GlobalKey<TextWidgetState> FSaleOrderNoKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> FPrdOrgIdKey = GlobalKey();

  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  var show = false;
  var isScanWork = false;
  var checkData;
  var checkDataChild;
  var selectData = {
    DateMode.YMD: '',
  };
  List<dynamic> orderDate = [];
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription _subscription;
  var _code;
  var _FNumber;

  @override
  void initState() {
    super.initState();

    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
    getWorkShop();
  }

  void getWorkShop() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.getString('FWorkShopName') != null) {
        FName = sharedPreferences.getString('FWorkShopName');
        FNumber = sharedPreferences.getString('FWorkShopNumber');
        isScanWork = true;
      } else {
        isScanWork = false;
      }
    });
  }

  @override
  void dispose() {
    this._textNumber.dispose();
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  // 用户的爱好集合
  List hobby = [];

  getOrderList() async {
    if (FNumber != '' && FBillNo != '') {
      Map<String, dynamic> userMap = Map();
      if (FDate != '') {
        userMap['FilterString'] =
        "FBillNo='$FBillNo' and FNoStockInQty>0 and FStatus in (3,4) and FWorkShopID.FNumber='$FNumber' and FDate='$FDate'";
      } else {
        userMap['FilterString'] =
        "FBillNo='$FBillNo' and FNoStockInQty>0 and FStatus in (3,4) and FWorkShopID.FNumber='$FNumber'";
      }
      userMap['FormId'] = 'PRD_MO';
      userMap['FieldKeys'] =
      'FBillNo,FPrdOrgId.FNumber,FPrdOrgId.FName,FDate,FSaleOrderNo,FTreeEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FWorkShopID.FNumber,FWorkShopID.FName,FUnitId.FNumber,FUnitId.FName,FQty,FPlanStartDate,FPlanFinishDate,FSrcBillNo,FNoStockInQty,FID,FStatus';
      Map<String, dynamic> dataMap = Map();
      dataMap['data'] = userMap;
      String order = await CurrencyEntity.polling(dataMap);
      orderDate = [];
      orderDate = jsonDecode(order);
      if (orderDate.length > 0) {
        FDate = orderDate[0][3].substring(0, 10);
        selectData[DateMode.YMD] = orderDate[0][3].substring(0, 10);
        FSaleOrderNo = orderDate[0][4];
        globalKey.currentState.update();
        /*FBillNoKey.currentState.onPressed(orderDate[0][0]);
    FSaleOrderNoKey.currentState.onPressed(orderDate[0][4]);*/
        hobby = [];
        orderDate.forEach((value) {
          List arr = [];
          arr.add({
            "title": "物料子码",
            "name": "FMaterialId",
            "value": {"label": value[6], "value": value[6]}
          });
          arr.add({
            "title": "生产车间",
            "name": "FWorkShopID",
            "value": {"label": value[10], "value": value[9]}
          });
          arr.add({
            "title": "预测批号",
            "name": "",
            "value": {"label": "", "value": ""}
          });
          arr.add({
            "title": "需生产数量",
            "name": "FQty",
            "value": {"label": value[13], "value": value[13]}
          });
          arr.add({
            "title": "良品数量",
            "name": "goodProductNumber",
            "value": {"label": value[13], "value": value[13]}
          });
          arr.add({
            "title": "良品仓库",
            "name": "goodProductStock",
            "value": {"label": "主仓", "value": "CK101001"}
          });
          arr.add({
            "title": "不合格数量",
            "name": "rejectsNumber",
            "value": {"label": "0", "value": "0"}
          });
          arr.add({
            "title": "不合格仓库",
            "name": "rejectsStock",
            "value": {"label": "次品仓", "value": "CK101004"}
          });
          hobby.add(arr);
        });
        checkItem = '';
        setState(() {
          EasyLoading.dismiss();
          this._getHobby();
        });
      } else {
        setState(() {
          EasyLoading.dismiss();
          this._getHobby();
        });
        ToastUtil.showInfo('无数据');
      }
    } else {
      EasyLoading.dismiss();
      _code = '';
      textKey.currentState.onPressed(_code);
      if (FNumber == '') {
        checkItem = 'FPrdOrgId';
        ToastUtil.showInfo('请扫描生产车间');
      } else if (FBillNo == '') {
        checkItem = 'FBillNo';
        ToastUtil.showInfo('请扫描生产单号');
      }
      scanDialog();
    }
  }

  void _onEvent(Object event) async {
    /*  setState(() {*/
    _code = event;
    if (textKey.currentState != null) {
      textKey.currentState.onPressed(_code);
      switch (checkItem) {
        case 'FBillNo':
          EasyLoading.show(status: 'loading...');
          Navigator.pop(context);
          FBillNo = _code;
          await getOrderList();
          break;
        case 'FPrdOrgId':
          EasyLoading.show(status: 'loading...');
          Navigator.pop(context);
          FName = _code.split(',')[1];
          FNumber = _code.split(',')[0];
          await getOrderList();
          break;
        case 'FNumber':
          Navigator.pop(context);
          setState(() {
            this.hobby[checkData][checkDataChild]["value"]["label"] = _FNumber;
            this.hobby[checkData][checkDataChild]['value']["value"] = _FNumber;
          });
          break;
        case 'FStock':
          Navigator.pop(context);
          setState(() {
            this.hobby[checkData][checkDataChild]["value"]['label'] =
            _code.split(',')[1];
            this.hobby[checkData][checkDataChild]['value']["value"] =
            _code.split(',')[0];
          });
          break;
      }
    } else {
      ToastUtil.showInfo('请点击扫描行扫描图标');
    }
    print("ChannelPage: $event");
    /*});*/
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
    });
  }

  Widget _item(title, var data, var selectData, {String label}) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () => _onClickItem(data, selectData, label: label),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              MyText(selectData.toString() ?? '暂无',
                  color: Colors.grey, rightpadding: 18),
              rightIcon
            ]),
          ),
        ),
        divider,
      ],
    );
  }

  Widget _dateItem(title, model) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () {
              _onDateClickItem(model);
            },
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              PartRefreshWidget(globalKey, () {
                //2、使用 创建一个widget
                return MyText(
                    PicketUtil.strEmpty(selectData[model])
                        ? '暂无'
                        : selectData[model],
                    color: Colors.grey,
                    rightpadding: 18);
              }),
              rightIcon
            ]),
          ),
        ),
        divider,
      ],
    );
  }

  void _onDateClickItem(model) {
    Pickers.showDatePicker(
      context,
      mode: model,
      suffix: Suffix.normal(),
      // selectDate: PDuration(month: 2),
      minDate: PDuration(year: 2020, month: 2, day: 10),
      maxDate: PDuration(second: 22),
      selectDate: (FDate == '' || FDate == null
          ? PDuration(year: 2021, month: 2, day: 10)
          : PDuration.parse(DateTime.parse(FDate))),
      // minDate: PDuration(hour: 12, minute: 38, second: 3),
      // maxDate: PDuration(hour: 12, minute: 40, second: 36),
      onConfirm: (p) {
        print('longer >>> 返回数据：$p');
        setState(() async {
          switch (model) {
            case DateMode.YMD:
              Map<String, dynamic> userMap = Map();
              selectData[model] = '${p.year}-${p.month}-${p.day}';
              FDate = '${p.year}-${p.month}-${p.day}';
              await getOrderList();
              break;
          }
        });
      },
      // onChanged: (p) => print(p),
    );
  }

  void _onClickItem(var data, var selectData, {String label}) {
    Pickers.showSinglePicker(
      context,
      data: data,
      selectData: selectData,
      pickerStyle: DefaultPickerStyle(),
      suffix: label,
      onConfirm: (p) {
        print('longer >>> 返回数据：$p');
        print('longer >>> 返回数据类型：${p.runtimeType}');
        setState(() {
          if (data == PickerDataType.sex) {
            /* FDate = p;*/
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('系统设置'),
              centerTitle: true,
            ),
            body: new ListView(padding: EdgeInsets.all(10), children: <Widget>[
              /* ListTile(
                leading: Icon(Icons.search),
                title: Text('版本信息'),
              ),
              Divider(
                height: 10.0,
                indent: 0.0,
                color: Colors.grey,
              ),*/
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('退出登录'),
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      },
                    ),
                  );
                },
              ),
              Divider(
                height: 10.0,
                indent: 0.0,
                color: Colors.grey,
              ),
            ]),
          );
        },
      ),
    );
  }

  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    this.hobby = [
      [
        {
          'title': "编码",
          'value': {"label": "0.01.01", "value": "123"}
        },{
        'title': "名称",
        'value': {"label": "A工具", "value": "123"}
      },{
        'title': "规格",
        'value': {"label": "10*10", "value": "123"}
      },{
        'title': "批号",
        'value': {"label": 20220218, "value": "123"}
      },{
        'title': "仓库",
        'value': {"label": "一仓", "value": "123"}
      },{
        'title': "出库数量",
        'value': {"label": 100, "value": "123"}
      },
      ]
    ];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (j == 4 || j == 6) {
          /*comList.add(
            _item(this.hobby[j]["title"], ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'],
                this.hobby[j]["value"]),
          );*/
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                    title: Text(this.hobby[i][j]["title"] +
                        '：' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing:
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                        icon: new Icon(Icons.filter_center_focus),
                        tooltip: '点击扫描',
                        onPressed: () {
                          this._FNumber = 0;
                          checkItem = 'FNumber';
                          this.show = false;
                          checkData = i;
                          checkDataChild = j;
                          scanDialog();
                          if (this.hobby[i][j]["value"]["label"] != 0) {
                            this._textNumber.value = _textNumber.value.copyWith(
                              text: this.hobby[i][j]["value"]["label"],
                            );
                          }
                        },
                      ),
                    ])),
              ),
              divider,
            ]),
          );
        } else if (j == 5 || j == 7) {
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                    title: Text(this.hobby[i][j]["title"] +
                        '：' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing:
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                        icon: new Icon(Icons.filter_center_focus),
                        tooltip: '点击扫描',
                        onPressed: () {
                          checkItem = 'FStock';
                          this.show = true;
                          checkData = i;
                          checkDataChild = j;
                          scanDialog();
                        },
                      ),
                    ])),
              ),
              divider,
            ]),
          );
        } else {
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                  title: Text(this.hobby[i][j]["title"] +
                      '：' +
                      this.hobby[i][j]["value"]["label"].toString()),
                  trailing:
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    /* MyText(orderDate[i][j],
                        color: Colors.grey, rightpadding: 18),*/
                  ]),
                ),
              ),
              divider,
            ]),
          );
        }
      }
      tempList.add(
        SizedBox(height: 10),
      );
      tempList.add(
        Column(
          children: comList,
        ),
      );
    }
    return tempList;
  }

  //调出弹窗 扫码
  void scanDialog() {
    showDialog<Widget>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('扫描',
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),
                  if (!show)
                    Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Card(
                            child: Column(children: <Widget>[
                              TextField(
                                style: TextStyle(color: Colors.black87),
                                keyboardType: TextInputType.number,
                                controller: this._textNumber,
                                decoration: InputDecoration(hintText: "输入或者扫描数量"),
                                onChanged: (value) {
                                  setState(() {
                                    this._FNumber = value;
                                  });
                                },
                              ),
                            ]))),
                  if (show)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TextWidget(textKey, ''),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // 关闭 Dialog
                          Navigator.pop(context);
                          if (checkItem == 'FNumber') {
                            setState(() {
                              this.hobby[checkData][checkDataChild]["value"]
                              ["label"] = _FNumber;
                              this.hobby[checkData][checkDataChild]['value']
                              ["value"] = _FNumber;
                            });
                          }
                        },
                        child: Text(
                          '确定',
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ).then((val) {
      print(val);
    });
  }

  pushDown(val, isGood) async {
    //下推
    Map<String, dynamic> pushMap = Map();
    pushMap['EntryIds'] = val;
    pushMap['RuleId'] = "PRD_MO2INSTOCK";
    pushMap['TargetFormId'] = "PRD_INSTOCK";
    pushMap['IsEnableDefaultRule'] = "false";
    pushMap['IsDraftWhenSaveFail'] = "false";
    var downData =
    await SubmitEntity.pushDown({"formid": "PRD_MO", "data": pushMap});
    print(downData);
    var res = jsonDecode(downData);
    //判断成功
    if (res['Result']['ResponseStatus']['IsSuccess']) {
      //查询入库单
      var entitysNumber =
      res['Result']['ResponseStatus']['SuccessEntitys'][0]['Number'];
      Map<String, dynamic> inOrderMap = Map();
      inOrderMap['FormId'] = 'PRD_INSTOCK';
      inOrderMap['FilterString'] = "FBillNo='$entitysNumber'";
      inOrderMap['FieldKeys'] =
      'FEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FUnitId.FNumber,FMoBillNo';
      String order = await CurrencyEntity.polling({'data': inOrderMap});
      print(order);
      var resData = jsonDecode(order);
      //组装数据
      Map<String, dynamic> dataMap = Map();
      dataMap['data'] = inOrderMap;
      Map<String, dynamic> orderMap = Map();
      orderMap['NeedUpDataFields'] = [
        'FStockStatusId',
        'FRealQty',
        'FInStockType'
      ];
      orderMap['IsDeleteEntry'] = false;
      Map<String, dynamic> Model = Map();
      Model['FID'] = res['Result']['ResponseStatus']['SuccessEntitys'][0]['Id'];
      // ignore: non_constant_identifier_names
      var FEntity = [];
      resData.forEach((entity) {
        this.hobby.forEach((element) {
          if (entity[1].toString() == element[0]['value']['value'].toString()) {
            // ignore: non_constant_identifier_names
            Map<String, dynamic> FEntityItem = Map();
            FEntityItem['FEntryID'] = entity[0];
            FEntityItem['FStockStatusId'] = {"FNumber": "KCZT01_SYS"};
            //判断良品，不良品
            if (isGood == "defective") {
              FEntityItem['FInStockType'] = '1';
              FEntityItem['FRealQty'] = element[4]['value']['value'];
              FEntity.add(FEntityItem);
            } else if (isGood == "nonDefective") {
              FEntityItem['FInStockType'] = '2';
              FEntityItem['FRealQty'] = element[6]['value']['value'];
              FEntity.add(FEntityItem);
            }
          }
        });
      });
      Model['FEntity'] = FEntity;
      orderMap['Model'] = Model;
      dataMap = {"formid": "PRD_INSTOCK", "data": orderMap};
      print(jsonEncode(dataMap));
      //返回保存参数
      return dataMap;
    } else {
      return false;
    }
  }

  //保存
  submitOder() async {
    var EntryIds1 = '';
    var EntryIds2 = '';
    //分两次读取良品，不良品数据
    for (var i = 0; i < 2; i++) {
      var hobbyIndex = 0;
      this.hobby.forEach((element) {
        if (i == 0) {
          if (double.parse(element[4]['value']['value']) > 0) {
            if (EntryIds1 == '') {
              EntryIds1 = orderDate[hobbyIndex][5].toString();
            } else {
              EntryIds1 = EntryIds1 + ',' + orderDate[hobbyIndex][5].toString();
            }
          }
        } else {
          if (double.parse(element[6]['value']['value']) > 0) {
            if (EntryIds2 == '') {
              EntryIds2 = orderDate[hobbyIndex][5].toString();
            } else {
              EntryIds2 = EntryIds2 + ',' + orderDate[hobbyIndex][5].toString();
            }
          }
        }
        hobbyIndex++;
      });
    }
    //判断是否填写数量
    if (EntryIds1 == '' && EntryIds2 == '') {
      ToastUtil.showInfo('无提交数据');
    } else {
      var checkList = [];
      //循环下推单据
      for (var i = 0; i < 2; i++) {
        if (EntryIds1 != '' && checkList.indexOf(EntryIds1) == -1) {
          checkList.add(EntryIds1);
          var resCheck = await this.pushDown(EntryIds1, 'defective');
          print(resCheck);
          if (resCheck != false) {
            var subData = await SubmitEntity.submit(resCheck);
            print(subData);
            if (subData != null) {
              var res = jsonDecode(subData);
              if (res != null) {
                if (res['Result']['ResponseStatus']['IsSuccess']) {
                  //提交清空页面
                  setState(() {
                    this.hobby = [];
                    this.orderDate = [];
                    this.FBillNo = '';
                    this.FSaleOrderNo = '';
                    ToastUtil.showInfo('提交成功');
                  });
                } else {
                  setState(() {
                    ToastUtil.showInfo(res['Result']['ResponseStatus']['Errors']
                    [0]['Message']);
                  });
                }
              }
            }
          } else {
            ToastUtil.showInfo('下推失败');
          }
        } else if (EntryIds2 != '' && checkList.indexOf(EntryIds2) == -1) {
          checkList.add(EntryIds2);
          var resCheck = await this.pushDown(EntryIds2, 'nonDefective');
          print(resCheck);
          if (resCheck != false) {
            var subData = await SubmitEntity.submit(resCheck);
            print(subData);
            if (subData != null) {
              var res = jsonDecode(subData);
              if (res != null) {
                if (res['Result']['ResponseStatus']['IsSuccess']) {
                  //提交清空页面
                  setState(() {
                    this.hobby = [];
                    this.orderDate = [];
                    this.FBillNo = '';
                    this.FSaleOrderNo = '';
                    ToastUtil.showInfo('提交成功');
                  });
                } else {
                  setState(() {
                    ToastUtil.showInfo(res['Result']['ResponseStatus']['Errors']
                    [0]['Message']);
                  });
                }
              }
            }
          } else {
            ToastUtil.showInfo('下推失败');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
          appBar: AppBar(
            title: Text("销售出库"),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView(children: <Widget>[
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          /* title: TextWidget(FBillNoKey, '生产订单：'),*/
                          title: Text("单号：$FBillNo"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  _dateItem('日期：', DateMode.YMD),
                  /*_item('部门', ['生产部'], '生产部'),*/
                  _item('仓库', ['一仓'], '一仓'),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('备注：'),
                          /*trailing: Column(children: <Widget>[
                            TextField(
                              style: TextStyle(color: Colors.black87),
                              keyboardType: TextInputType.number,
                              controller: this._textNumber,
                              decoration: InputDecoration(hintText: "备注"),
                              onChanged: (value) {
                                setState(() {
                                  this._FNumber = value;
                                });
                              },
                            )
                          ]),*/
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: this._getHobby(),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("保存"),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (this.hobby.length > 0) {
                            Map<String, dynamic> dataMap = Map();
                            var numbers = [];
                            dataMap['formid'] = 'PRD_MO';
                            dataMap['opNumber'] = 'toStart';
                            var hobbyIndex = 0;
                            this.hobby.forEach((list) {
                              Map<String, dynamic> entityMap = Map();
                              entityMap['Id'] = orderDate[hobbyIndex][18];
                              entityMap['EntryIds'] = orderDate[hobbyIndex][5];
                              numbers.add(entityMap);
                              hobbyIndex++;
                            });
                            dataMap['data'] = {'PkEntryIds': numbers};
                            var status =
                            await SubmitEntity.alterStatus(dataMap);
                            print(status);
                            if (status != null) {
                              var res = jsonDecode(status);
                              print(res);
                              if (res != null) {
                                if (res['Result']['ResponseStatus']
                                ['IsSuccess']) {
                                  submitOder();
                                } else {
                                  ToastUtil.showInfo(res['Result']
                                  ['ResponseStatus']['Errors'][0]
                                  ['Message']);
                                }
                              }
                            }
                          } else {
                            ToastUtil.showInfo('无提交数据');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
