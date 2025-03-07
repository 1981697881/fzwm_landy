import 'dart:convert';
import 'dart:math';
import 'package:fzwm_landy/model/currency_entity.dart';
import 'package:fzwm_landy/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:qrscan/qrscan.dart' as scanner;

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class StockPage extends StatefulWidget {
  StockPage({Key ?key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  //搜索字段
  String keyWord = '';
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);

  static const scannerPlugin =
      const EventChannel('com.shinow.pda_scanner/plugin');
   StreamSubscription ?_subscription;
  var _code;

  List<dynamic> orderDate = [];
  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
    EasyLoading.dismiss();
  }

  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }

  // 集合
  List hobby = [];
  getOrderList() async {
    EasyLoading.show(status: 'loading...');
      Map<String, dynamic> userMap = Map();
      if(this.keyWord != ''){
        var number = this.keyWord.split(',');
        userMap['FilterString'] =
        "FMaterialId.FNumber='"+number[0]+"' and FBaseQty>0";
      }
      userMap['FormId'] = 'STK_Inventory';
      userMap['FieldKeys'] =
          'FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FBaseQty';
      Map<String, dynamic> dataMap = Map();
      dataMap['data'] = userMap;
      String order = await CurrencyEntity.polling(dataMap);
      orderDate = [];
      orderDate = jsonDecode(order);
      print(orderDate);
    hobby = [];
    if (orderDate.length > 0) {
        orderDate.forEach((value) {
          List arr = [];
          arr.add({
            "title": "编码",
            "name": "FMaterialFNumber",
            "value": {"label": value[0], "value": value[0]}
          });
          arr.add({
            "title": "名称",
            "name": "FMaterialFName",
            "value": {"label": value[1], "value": value[1]}
          });
          arr.add({
            "title": "规格",
            "name": "FMaterialIdFSpecification",
            "value": {"label": value[2], "value": value[2]}
          });
          arr.add({
            "title": "仓库",
            "name": "FStockIdFName",
            "value": {"label": value[3], "value": value[3]}
          });
          arr.add({
            "title": "库存数量",
            "name": "FBaseQty",
            "value": {"label": value[4], "value": value[4]}
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

  void _onEvent(event) async {
    /*  setState(() {*/
    _code = event;
    EasyLoading.show(status: 'loading...');
    keyWord = _code;
    this.controller.text = _code;
    await getOrderList();
    /*});*/
  }
  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
    });
  }

  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
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

//扫码函数,最简单的那种
  Future scan() async {
    String cameraScanResult = await scanner.scan(); //通过扫码获取二维码中的数据
    getScan(cameraScanResult); //将获取到的参数通过HTTP请求发送到服务器
    print(cameraScanResult); //在控制台打印
  }

//用于验证数据(也可以在控制台直接打印，但模拟器体验不好)
  void getScan(String scan) async {
    keyWord = scan;
    this.controller.text = scan;
    await getOrderList();
  }

  @override
  Widget build(BuildContext context) {

    return FlutterEasyLoading(
      /*child: MaterialApp(
      title: "loging",*/
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: scan,
            tooltip: 'Increment',
            child: Icon(Icons.filter_center_focus),
          ),
          appBar: AppBar(
            /* leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),*/
            title: Text("库存查询"),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                    minHeight: 50, //收起的高度
                    maxHeight: 50, //展开的最大高度
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Container(
                          height: 52.0,
                          child: new Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: new Card(
                                child: new Container(
                                  child: new Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 6.0,
                                      ),
                                      Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            controller:  this.controller,
                                            decoration: new InputDecoration(
                                                contentPadding:
                                                EdgeInsets.only(
                                                    bottom: 12.0),
                                                hintText: '输入关键字',
                                                border: InputBorder.none),
                                            onSubmitted: (value) {
                                              setState(() {
                                                this.keyWord  = value;
                                                this.getOrderList();

                                              });
                                            },
                                            // onChanged: onSearchTextChanged,
                                          ),
                                        ),
                                      ),
                                      new IconButton(
                                        icon: new Icon(Icons.cancel),
                                        color: Colors.grey,
                                        iconSize: 18.0,
                                        onPressed: () {
                                          this.controller.clear();
                                          // onSearchTextChanged('');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),
                ),
              ),
              SliverFillRemaining(
                child: ListView(children: <Widget>[
                  Column(
                    children: this._getHobby(),
                  ),
                ]),
              ),
            ],
          )),
    );
    /*);*/
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Container child;
  final double minHeight;
  final double maxHeight;
  StickyTabBarDelegate({required this.minHeight,
  required this.maxHeight,required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}