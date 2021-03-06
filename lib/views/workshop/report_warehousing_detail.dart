import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:fzwm_landy/model/currency_entity.dart';
import 'package:fzwm_landy/model/submit_entity.dart';
import 'package:fzwm_landy/utils/handler_order.dart';
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
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class ReportWarehousingDetail extends StatefulWidget {
  var FBillNo;

  ReportWarehousingDetail({Key ?key, @required this.FBillNo}) : super(key: key);

  @override
  _ReportWarehousingDetailState createState() => _ReportWarehousingDetailState(FBillNo);
}

class _ReportWarehousingDetailState extends State<ReportWarehousingDetail> {
  var _remarkContent = new TextEditingController();
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();

  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  var show = false;
  var isSubmit = false;
  var isScanWork = false;
  var checkData;
  var checkDataChild;

  var selectData = {
    DateMode.YMD: "",
  };
  List<dynamic> orderDate = [];
  List<dynamic> collarOrderDate = [];
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
   StreamSubscription ?_subscription;
  var _code;
  var _FNumber;
  var fBillNo;

  _ReportWarehousingDetailState(FBillNo) {
    if (FBillNo != null) {
      this.fBillNo = FBillNo['value'];
      this.getOrderList();
    }else{
      this.fBillNo = '';
    }
  }

  @override
  void initState() {
    super.initState();
    DateTime dateTime = DateTime.now();
    var nowDate = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    selectData[DateMode.YMD] = nowDate;
    EasyLoading.dismiss();
    /// ????????????
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

    /// ????????????
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }

  // ??????????????????
  List hobby = [];

  getOrderList() async {
    Map<String, dynamic> userMap = Map();
    print(fBillNo);
    userMap['FilterString'] = "FFinishQty>0 and FBillNo='$fBillNo'";
    userMap['FormId'] = 'PRD_MORPT';
    userMap['FieldKeys'] =
    'FBillNo,FPrdOrgId.FNumber,FPrdOrgId.FName,FDate,FEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FWorkshipId.FNumber,FWorkshipId.FName,FUnitId.FNumber,FUnitId.FName,FFinishQty,FProduceDate,FQuaQty,FFailQty,FSrcBillNo,FStockInSelQty,FID';
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String order = await CurrencyEntity.polling(dataMap);
    orderDate = [];
    orderDate = jsonDecode(order);
    FDate = formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd,]);
    selectData[DateMode.YMD] = formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd,]);
    if (orderDate.length > 0) {
      hobby = [];
      orderDate.forEach((value) {
        List arr = [];
        arr.add({
          "title": "????????????",
          "name": "FMaterial",
          "isHide": false,
          "value": {"label": value[6] + "- (" + value[5] + ")", "value": value[5]}
        });
        arr.add({
          "title": "????????????",
          "isHide": false,
          "name": "FMaterialIdFSpecification",
          "value": {"label": value[7], "value": value[7]}
        });
        arr.add({
          "title": "????????????",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": value[11], "value": value[10]}
        });
        arr.add({
          "title": "????????????",
          "name": "FQuaQty",
          "isHide": false,
          "value": {"label": value[14], "value": value[14]}
        });
        arr.add({
          "title": "???????????????",
          "name": "FFailQty",
          "isHide": false,
          "value": {"label": value[15], "value": value[15]}
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
      ToastUtil.showInfo('?????????');
    }
  }

  void _onEvent(event) async {
    /*  setState(() {*/
    _code = event;
    print("ChannelPage: $event");
    /*});*/
  }

  void _onError(Object error) {
    setState(() {
      _code = "????????????";
    });
  }

  Widget _item(title, var data, selectData, hobby, {String ?label,var stock}) {
    if (selectData == null) {
      selectData = "";
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () => data.length>0?_onClickItem(data, selectData, hobby, label: label,stock: stock):{ToastUtil.showInfo('?????????')},
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              MyText(selectData.toString()=="" ? '??????':selectData.toString(),
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
                //2????????? ????????????widget
                return MyText(
                    (PicketUtil.strEmpty(selectData[model])
                        ? '??????'
                        : selectData[model])!,
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
        print('longer >>> ???????????????$p');
        setState(() {
          switch (model) {
            case DateMode.YMD:
              selectData[model] = formatDate(DateFormat('yyyy-MM-dd').parse('${p.year}-${p.month}-${p.day}'), [yyyy, "-", mm, "-", dd,]);
              FDate = formatDate(DateFormat('yyyy-MM-dd').parse('${p.year}-${p.month}-${p.day}'), [yyyy, "-", mm, "-", dd,]);
              break;
          }
        });
      },
      // onChanged: (p) => print(p),
    );
  }

  void _onClickItem(var data, var selectData, hobby, {String ?label,var stock}) {
    Pickers.showSinglePicker(
      context,
      data: data,
      selectData: selectData,
      pickerStyle: DefaultPickerStyle(),
      suffix: label,
      onConfirm: (p) {
        print('longer >>> ???????????????$p');
        print('longer >>> ?????????????????????${p.runtimeType}');
        setState(() {
          if (data == PickerDataType.sex) {
            /* FDate = p;*/
          }
        });
      },
    );
  }
  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (!this.hobby[i][j]['isHide']) {
          if (j == 3 || j == 4) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '???' +
                          this.hobby[i][j]["value"]["label"].toString()),
                      trailing:
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        IconButton(
                          icon: new Icon(Icons.filter_center_focus),
                          tooltip: '????????????',
                          onPressed: () {
                            this._textNumber.text =
                                this.hobby[i][j]["value"]["label"].toString();
                            this._FNumber =
                                this.hobby[i][j]["value"]["label"].toString();
                            checkItem = 'FNumber';
                            this.show = false;
                            checkData = i;
                            checkDataChild = j;
                            scanDialog();
                            print(this.hobby[i][j]["value"]["label"]);
                            if (this.hobby[i][j]["value"]["label"] != 0) {
                              this._textNumber.value = _textNumber.value.copyWith(
                                text:
                                this.hobby[i][j]["value"]["label"].toString(),
                              );
                            }
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
                        '???' +
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

  //???????????? ??????
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
                    child: Text('????????????',
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
                              decoration: InputDecoration(hintText: "??????"),
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
                          // ?????? Dialog
                          Navigator.pop(context);
                          setState(() {
                            this.hobby[checkData][checkDataChild]["value"]
                            ["label"] = _FNumber;
                            this.hobby[checkData][checkDataChild]['value']
                            ["value"] = _FNumber;
                          });
                        },
                        child: Text(
                          '??????',
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

  pushDown(val, type) async {
    //??????
    Map<String, dynamic> pushMap = Map();
    pushMap['EntryIds'] = val;
    pushMap['RuleId'] = "PRD_MODIRECTSENDTOINSTOCK";
    pushMap['TargetFormId'] = "PRD_INSTOCK";
    pushMap['IsEnableDefaultRule'] = "false";
    pushMap['IsDraftWhenSaveFail'] = "false";
    var downData =
    await SubmitEntity.pushDown({"formid": "PRD_MORPT", "data": pushMap});
    var res = jsonDecode(downData);
    print(res);
    //????????????
    if (res['Result']['ResponseStatus']['IsSuccess']) {
      //???????????????
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
      //????????????
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
      for (int entity = 0; entity < resData.length; entity++) {
        /*resData.forEach((entity) {*/
        for (int element = 0; element < this.hobby.length; element++) {
          /*this.hobby.forEach((element) {*/
          if (resData[entity][1].toString() ==
              this.hobby[element][0]['value']['value'].toString()) {
            // ignore: non_constant_identifier_names
            //???????????????????????????
            if (type == "defective") {
              Map<String, dynamic> FEntityItem = Map();
              FEntityItem['FEntryID'] = resData[entity][0];
              FEntityItem['FStockStatusId'] = {"FNumber": "KCZT01_SYS"};
              FEntityItem['FInStockType'] = '1';
              FEntityItem['FRealQty'] =
              this.hobby[element][3]['value']['value'];
              FEntityItem['FStockId'] = {
                "FNumber": 'CK101001'
              };
              FEntity.add(FEntityItem);
            } else {
              Map<String, dynamic> FEntityItem = Map();
              FEntityItem['FInStockType'] = '2';
              FEntityItem['FStockStatusId'] = {"FNumber": "KCZT01_SYS"};
              FEntityItem['FEntryID'] = resData[entity][0];
              FEntityItem['FRealQty'] =
              this.hobby[element][4]['value']['value'];
              FEntityItem['FStockId'] = {
                "FNumber": 'CK101004'
              };
              FEntity.add(FEntityItem);
            }
          }
        } /*);*/
      }
      /*);*/
      Model['FEntity'] = FEntity;
      /* Model['FStockOrgId'] = {"FNumber": orderDate[0][22]};
      Model['FPrdOrgId'] = {"FNumber": orderDate[0][22]};*/
      orderMap['Model'] = Model;
      dataMap = {"formid": "PRD_INSTOCK", "data": orderMap, "isBool": true};
      print(jsonEncode(dataMap));
      //??????????????????
      return dataMap;
    } else {
      Map<String, dynamic> errorMap = Map();
      errorMap = {
        "msg": res['Result']['ResponseStatus']['Errors'][0]['Message'],
        "isBool": false
      };
      return errorMap;
    }
  }
  //??????
  submitOder() async {
    if (this.hobby.length > 0) {
      setState(() {
        this.isSubmit = true;
      });
      var EntryIds1 = '';
      var EntryIds2 = '';
      //???????????????????????????????????????
      for (var i = 0; i < 2; i++) {
        var hobbyIndex = 0;
        this.hobby.forEach((element) {
          if (i == 0) {
            if (element[3]['value']['value'] is String) {
              if (double.parse(element[3]['value']['value']) > 0) {
                if (EntryIds1 == '') {
                  EntryIds1 = orderDate[hobbyIndex][4].toString();
                } else {
                  EntryIds1 =
                      EntryIds1 + ',' + orderDate[hobbyIndex][4].toString();
                }
              }
            } else {
              if (element[3]['value']['value'] > 0) {
                if (EntryIds1 == '') {
                  EntryIds1 = orderDate[hobbyIndex][4].toString();
                } else {
                  EntryIds1 =
                      EntryIds1 + ',' + orderDate[hobbyIndex][4].toString();
                }
              }
            }
          } else {
            if (element[4]['value']['value'] is String) {
              if (double.parse(element[4]['value']['value']) > 0) {
                if (EntryIds2 == '') {
                  EntryIds2 = orderDate[hobbyIndex][5].toString();
                } else {
                  EntryIds2 =
                      EntryIds2 + ',' + orderDate[hobbyIndex][5].toString();
                }
              }
            } else {
              if (element[4]['value']['value'] > 0) {
                if (EntryIds2 == '') {
                  EntryIds2 = orderDate[hobbyIndex][5].toString();
                } else {
                  EntryIds2 =
                      EntryIds2 + ',' + orderDate[hobbyIndex][5].toString();
                }
              }
            }
          }
          hobbyIndex++;
        });
      }
      //????????????????????????
      if (EntryIds1 == '' && EntryIds2 == '') {
        ToastUtil.showInfo('???????????????');
      } else {
        var checkList = [];
        //??????????????????
        for (var i = 0; i < 2; i++) {
          if (EntryIds1 != '' && i == 0) {
            checkList.add(EntryIds1);
            var resCheck = await this.pushDown(EntryIds1, 'defective');
            if (resCheck['isBool'] != false) {
              var subData = await SubmitEntity.save(resCheck);
              var res = jsonDecode(subData);
              if (res != null) {
                if (res['Result']['ResponseStatus']['IsSuccess']) {
                  //??????????????????
                  Map<String, dynamic> auditMap = Map();
                  auditMap = {
                    "formid": "PRD_INSTOCK",
                    "data": {
                      'Ids': res['Result']['ResponseStatus']['SuccessEntitys']
                      [0]['Id']
                    }
                  };
                  //??????
                  HandlerOrder.orderHandler(context,auditMap,1,"PRD_INSTOCK",SubmitEntity.submit(auditMap)).then((submitResult) {
                    if(submitResult){
                      //??????
                      HandlerOrder.orderHandler(context,auditMap,1,"PRD_INSTOCK",SubmitEntity.audit(auditMap)).then((auditResult) {
                        if(auditResult){
                          //??????????????????
                          setState(() {
                            this.hobby = [];
                            this.orderDate = [];
                            this.FBillNo = '';
                            ToastUtil.showInfo('????????????');
                            Navigator.of(context).pop("refresh");
                          });
                        }else{
                          //???????????????
                          HandlerOrder.orderHandler(context,auditMap,0,"PRD_INSTOCK",SubmitEntity.unAudit(auditMap)).then((unAuditResult) {
                            if(unAuditResult){
                              this.isSubmit = false;
                            }
                          });
                        }
                      });
                    }else{
                      this.isSubmit = false;
                    }
                  });
                } else {
                  Map<String, dynamic> deleteMap = Map();
                  deleteMap = {
                    "formid": "PRD_INSTOCK",
                    "data": {'Ids': resCheck['data']["Model"]["FID"]}
                  };
                  HandlerOrder.orderDelete(context,deleteMap,res['Result']['ResponseStatus']['Errors'][0]['Message']);
                }
              }
            } else {
              setState(() {
                this.isSubmit = false;
                ToastUtil.errorDialog(context, resCheck['msg']);
              });
              break;
            }
          } else if (EntryIds2 != '' && i == 1) {
            checkList.add(EntryIds2);
            var resCheck = await this.pushDown(EntryIds2, 'nonDefective');
            if (resCheck['isBool'] != false) {
              var subData = await SubmitEntity.save(resCheck);
              print(subData);
              var res = jsonDecode(subData);
              if (res != null) {
                if (res['Result']['ResponseStatus']['IsSuccess']) {
                  //??????????????????
                  Map<String, dynamic> auditMap = Map();
                  auditMap = {
                    "formid": "PRD_INSTOCK",
                    "data": {
                      'Ids': res['Result']['ResponseStatus']['SuccessEntitys']
                      [0]['Id']
                    }
                  };
                  //??????
                  HandlerOrder.orderHandler(context,auditMap,1,"PRD_INSTOCK",SubmitEntity.submit(auditMap)).then((submitResult) {
                    if(submitResult){
                      //??????
                      HandlerOrder.orderHandler(context,auditMap,1,"PRD_INSTOCK",SubmitEntity.audit(auditMap)).then((auditResult) {
                        if(auditResult){
                          //??????????????????
                          setState(() {
                            this.hobby = [];
                            this.orderDate = [];
                            this.FBillNo = '';
                            ToastUtil.showInfo('????????????');
                            Navigator.of(context).pop("refresh");
                          });
                        }else{
                          //???????????????
                          HandlerOrder.orderHandler(context,auditMap,0,"PRD_INSTOCK",SubmitEntity.unAudit(auditMap)).then((unAuditResult) {
                            if(unAuditResult){
                              this.isSubmit = false;
                            }
                          });
                        }
                      });
                    }else{
                      this.isSubmit = false;
                    }
                  });
                } else {
                  Map<String, dynamic> deleteMap = Map();
                  deleteMap = {
                    "formid": "PRD_INSTOCK",
                    "data": {'Ids': resCheck['data']["Model"]["FID"]}
                  };
                  HandlerOrder.orderDelete(context,deleteMap,res['Result']['ResponseStatus']['Errors'][0]['Message']);
                }
              }
            } else {
              setState(() {
                this.isSubmit = false;
                ToastUtil.errorDialog(context, resCheck['msg']);
              });
              break;
            }
          }
        }

      }
    } else {
      ToastUtil.showInfo('???????????????');
    }
  }
  /// ???????????????????????????
  Future<void> _showSumbitDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("????????????"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('??????'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('??????'),
                onPressed: () {
                  Navigator.of(context).pop();
                  submitOder();
                },
              )
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
          appBar: AppBar(
            title: Text("????????????"),
            centerTitle: true,
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
              Navigator.of(context).pop("refresh");
            }),
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
                          /* title: TextWidget(FBillNoKey, '???????????????'),*/
                          title: Text("?????????$fBillNo"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  _dateItem('?????????', DateMode.YMD),
                  /*_item('??????', ['?????????'], '?????????'),*/
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                            //??????????????????
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "??????",
                              //?????????????????????
                              border: OutlineInputBorder(),
                            ),
                            controller: this._remarkContent,
                            //????????????
                            onChanged: (value) {
                              setState(() {
                                _remarkContent.value = TextEditingValue(
                                  text: value,
                                  selection: TextSelection.fromPosition(TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: value.length)));
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
                        child: Text("??????"),
                        color: this.isSubmit?Colors.grey:Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async=> this.isSubmit ? null : _showSumbitDialog(),
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
