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

class ReturnGoodsDetail extends StatefulWidget {
  var FBillNo;

  ReturnGoodsDetail({Key key, @required this.FBillNo}) : super(key: key);

  @override
  _ReturnGoodsDetailState createState() => _ReturnGoodsDetailState(FBillNo);
}

class _ReturnGoodsDetailState extends State<ReturnGoodsDetail> {
  var _remarkContent = new TextEditingController();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();

  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String cusName = '';
  String FNumber = '';
  String FDate = '';
  var show = false;
  var isScanWork = false;
  var checkData;
  var checkDataChild;
  var selectData = {
    DateMode.YMD: '',
  };
  var stockList = [];
  List<dynamic> stockListObj = [];
  List<dynamic> orderDate = [];
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  static const scannerPlugin =
      const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription _subscription;
  var _code;
  var _FNumber;
  var fBillNo;

  _ReturnGoodsDetailState(fBillNo) {
    this.fBillNo = fBillNo['value'];
    this.getOrderList();
  }

  @override
  void initState() {
    super.initState();
    DateTime dateTime = DateTime.now();
    var nowDate = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    selectData[DateMode.YMD] = nowDate;

    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
    getWorkShop();
    getStockList();
  }
  //获取仓库
  getStockList() async {
    Map<String, dynamic> userMap = Map();
    userMap['FormId'] = 'BD_STOCK';
    userMap['FieldKeys'] = 'FStockID,FName,FNumber';
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String res = await CurrencyEntity.polling(dataMap);
    stockListObj = jsonDecode(res);
    stockListObj.forEach((element) {
      stockList.add(element[1]);
    });
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
    Map<String, dynamic> userMap = Map();
    print(fBillNo);
    userMap['FilterString'] = "FJoinRetQty>0 and fBillNo='$fBillNo'";
    userMap['FormId'] = 'SAL_RETURNNOTICE';
    userMap['FieldKeys'] =
        'FBillNo,FSaleOrgId.FNumber,FSaleOrgId.FName,FDate,FEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FRetorgId.FNumber,FRetorgId.FName,FUnitId.FNumber,FUnitId.FName,FQty,FDeliveryDate,FJoinRetQty,FID,FRetcustId.FNumber,FRetcustId.FName';
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String order = await CurrencyEntity.polling(dataMap);
    orderDate = [];
    orderDate = jsonDecode(order);
    print(orderDate);
    if (orderDate.length > 0) {
      this.FBillNo = orderDate[0][0];
      this.cusName = orderDate[0][17];
      hobby = [];
      orderDate.forEach((value) {
        List arr = [];
        arr.add({
          "title": "单据编号",
          "name": "FBillNo",
          "isHide": true,
          "value": {"label": value[0], "value": value[0]}
        });
        arr.add({
          "title": "销售组织",
          "name": "FSaleOrgId",
          "isHide": true,
          "value": {"label": value[2], "value": value[1]}
        });
        arr.add({
          "title": "客户",
          "name": "FSaleOrgId",
          "isHide": true,
          "value": {"label": value[17], "value": value[16]}
        });
        arr.add({
          "title": "单据日期",
          "name": "FDate",
          "isHide": true,
          "value": {"label": value[3], "value": value[3]}
        });
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
          "value": {"label": value[5], "value": value[4]}
        });
        arr.add({
          "title": "规格型号",
          "name": "FMaterialIdFSpecification",
          "isHide": false,
          "value": {"label": value[6], "value": value[6]}
        });
        arr.add({
          "title": "单位名称",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": value[11], "value": value[10]}
        });
        arr.add({
          "title": "数量",
          "name": "FBaseQty",
          "isHide": false,
          "value": {"label": value[12], "value": value[12]}
        });
        arr.add({
          "title": "退货日期",
          "name": "FDeliverydate",
          "isHide": true,
          "value": {"label": value[13], "value": value[13]}
        });
        arr.add({
          "title": "退货数量",
          "name": "FJoinRetQty",
          "isHide": false,
          "value": {"label": value[14], "value": value[14]}
        });
        arr.add({
          "title": "仓库",
          "name": "FStockId",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        hobby.add(arr);
      });
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
  }

  void _onEvent(Object event) async {
    /*  setState(() {*/
    _code = event;
    print("ChannelPage: $event");
    /*});*/
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
    });
  }

  Widget _item(title, var data, selectData, hobby, {String label}) {
    if (selectData == null) {
      selectData = "";
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () => _onClickItem(data, selectData, hobby, label: label),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              MyText(hobby['value']['label'].toString() ?? '暂无',
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

  void _onClickItem(var data, var selectData, hobby, {String label}) {
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
          hobby['value']['label'] = p;
          var elementIndex = 0;
          stockList.forEach((element) {
            if (element == p) {
              hobby['value']['value'] = stockListObj[elementIndex][2];
            }
            elementIndex++;
          });
          print(hobby);
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
              leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                Navigator.of(context).pop("refresh");
              }),
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
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (!this.hobby[i][j]['isHide']) {
          if (j == 7) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '：' +
                          this.hobby[i][j]["value"]["label"].toString()),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: new Icon(Icons.filter_center_focus),
                              tooltip: '点击扫描',
                              onPressed: () {
                                this._textNumber.text =
                                this.hobby[i][j]["value"]["label"];
                                this._FNumber =
                                this.hobby[i][j]["value"]["label"];
                                checkData = i;
                                checkDataChild = j;
                                scanDialog();
                                if (this.hobby[i][j]["value"]["label"] != 0) {
                                  this._textNumber.value =
                                      _textNumber.value.copyWith(
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
          } else if (j == 10) {
            comList.add(
              _item('仓库:', stockList, this.hobby[i][j]['label'],
                  this.hobby[i][j]),
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
                  /*  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('输入数量',
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),*/
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Card(
                          child: Column(children: <Widget>[
                            TextField(
                              style: TextStyle(color: Colors.black87),
                              keyboardType: TextInputType.number,
                              controller: this._textNumber,
                              decoration: InputDecoration(hintText: "输入数量"),
                              onChanged: (value) {
                                setState(() {
                                  this._FNumber = value;
                                });
                              },
                            ),
                          ]))),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // 关闭 Dialog
                          Navigator.pop(context);
                          setState(() {
                            this.hobby[checkData][checkDataChild]["value"]
                            ["label"] = _FNumber;
                            this.hobby[checkData][checkDataChild]['value']
                            ["value"] = _FNumber;
                          });
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
            title: Text("销售退货"),
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
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          /* title: TextWidget(FBillNoKey, '生产订单：'),*/
                          title: Text("客户：$cusName"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  _dateItem('日期：', DateMode.YMD),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                          //最多输入行数
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "备注",
                            //给文本框加边框
                            border: OutlineInputBorder(),
                          ),
                          controller: this._remarkContent,
                          //改变回调
                          onChanged: (value) {
                            setState(() {
                              _remarkContent.text = value;
                            });
                          },
                        ),
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
