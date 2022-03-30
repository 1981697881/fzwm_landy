import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fzwm_landy/views/production/warehousing_page.dart';
import 'package:fzwm_landy/views/sale/retrieval_page.dart';
import 'package:fzwm_landy/views/sale/return_goods_page.dart';
import 'package:fzwm_landy/views/stock/stock_page.dart';

class MenuPermissions {
  static void getMenu() async {}

  static void getMenuChild() async {
    var list = [
      "201801004",
      "手机事业部",
      "A",
      true,
      "SCDD",
      false,
      "",
      true,
      "FHTZD",
      true,
      "THTZD",
      true,
      "SLTZD",
      true,
      "DTPD",
      true,
      "",
      true,
      "",
      false,
      "",
      false,
      "",
      false,
      false,
      false
    ];
    list.removeAt(0);
    list.removeAt(0);
    list.removeAt(0);
    print(list);
    var menu = [];
    for (var i = 0; i < list.length; i++) {
      switch (i) {
        case 0:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "生产入库",
              "parentId": 1,
              "color": Colors.pink.withOpacity(0.7),
              "router": WarehousingPage(),
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 2:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "生产领料",
              "parentId": 1,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 4:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "销售出库",
              "parentId": 2,
              "color": Colors.pink.withOpacity(0.7),
              "router": RetrievalPage(),
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 6:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "销售退货",
              "parentId": 2,
              "color": Colors.pink.withOpacity(0.7),
              "router": ReturnGoodsPage(),
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 8:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "采购入库",
              "parentId": 1,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 10:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "盘点",
              "parentId": 3,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 12:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "其他入库",
              "parentId": 4,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 14:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "其他出库",
              "parentId": 4,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 16:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "工序派工",
              "parentId": 4,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 18:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "工序汇报",
              "parentId": 4,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 20:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "上架",
              "parentId": 3,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 22:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "下架",
              "parentId": 3,
              "color": Colors.pink.withOpacity(0.7),
              "router": "",
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
        case 24:
          if (list[i] == true) {
            var obj = {
              "icon": Icons.loupe,
              "text": "库存查询",
              "parentId": 3,
              "color": Colors.pink.withOpacity(0.7),
              "router": StockPage(),
              "source": list[i + 1],
            };
            menu.add(obj);
          }
          break;
      }
    }
    return menu;
  }
}
