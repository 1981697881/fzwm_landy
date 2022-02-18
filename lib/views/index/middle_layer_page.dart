import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fzwm_landy/views/drawing/drawing_page.dart';
import 'package:fzwm_landy/views/production/warehousing_detail.dart';
import 'package:fzwm_landy/views/production/warehousing_page.dart';
import 'package:fzwm_landy/views/sale/retrieval_detail.dart';
import 'package:fzwm_landy/views/sale/retrieval_page.dart';
import 'package:fzwm_landy/views/sale/return_goods_detail.dart';
import 'package:fzwm_landy/views/sale/return_goods_page.dart';
import 'package:fzwm_landy/views/stock/stock_page.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class MiddleLayerPage extends StatefulWidget {
  final int menuId;
  final String menuTitle;

  MiddleLayerPage({Key key,@required this.menuId,@required this.menuTitle}) : super(key: key);

  @override
  _MiddleLayerPageState createState() => _MiddleLayerPageState(menuId,menuTitle);
}

class _MiddleLayerPageState extends State<MiddleLayerPage> {
  int currentIndex;
  String menuTitle;
  _MiddleLayerPageState(int menuId, String menuTitle){
    this.currentIndex = menuId;
    this.menuTitle = menuTitle;
    print(currentIndex);
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*一个渐变颜色的正方形集合*/
  List<Widget> Boxs(List<Map<String, dynamic>> menu) =>
      List.generate(menu.length, (index) {
        return Container(
            width: 150,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(4.0, 15.0), //阴影xy轴偏移量
                    blurRadius: 15.0, //阴影模糊程度
                    spreadRadius: 1.0 //阴影扩散程度
                    )
              ],
              borderRadius: BorderRadius.all(
                //圆角
                Radius.circular(10.0),
              ),
              gradient: LinearGradient(colors: [
                Colors.lightBlueAccent,
                Colors.blue,
                Colors.blueAccent
              ]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => menu[index]['router']),
                    );
                  },
                  child: Container(
                    child: Text(
                      menu[index]['text'],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ));
      });

  // tabs 容器
  Widget buildAppBarTabs() {
    var menu = [
      {
        "icon": Icons.loupe,
        "text": "生产入库",
        "parentId": 1,
        "color": Colors.pink.withOpacity(0.7),
        "router": WarehousingPage()
      },
      {
        "icon": Icons.local_shipping,
        "text": "销售出库",
        "parentId": 2,
        "color": Colors.pink.withOpacity(0.7),
        "router": RetrievalPage()
      }, {
        "icon": Icons.local_shipping,
        "text": "销售退货",
        "parentId": 2,
        "color": Colors.pink.withOpacity(0.7),
        "router": ReturnGoodsPage()
      },
      {
        "icon": Icons.web,
        "text": "库存浏览",
        "parentId": 3,
        "color": Colors.pink.withOpacity(0.7),
        "router": StockPage()
      },
      {
        "icon": Icons.wallpaper,
        "text": "图纸查询",
        "parentId": 4,
        "color": Colors.pink.withOpacity(0.7),
        "router": DrawingPage()
      },
    ];
    var childMenu = List<Map<String, dynamic>>();
    menu.forEach((value) {
      if(value['parentId'] == this.currentIndex){
        print(value);
        childMenu.add(value);
      }
    });
    return Wrap(
        spacing: 20, //主轴上子控件的间距
        runSpacing: 20, //交叉轴上子控件之间的间距
        children: Boxs(childMenu));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(this.menuTitle),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 10.0),
              padding: EdgeInsets.symmetric(
                // 同appBar的titleSpacing一致
                horizontal: NavigationToolbar.kMiddleSpacing,
                vertical: 20.0,
              ),
              child: buildAppBarTabs(),
            ),
          ],
        ),
      ),
    );
  }
}
