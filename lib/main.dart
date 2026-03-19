import 'package:campus_wallet/expense_chart.dart';
import 'package:flutter/material.dart';
import 'expense_form.dart';
import 'expense_list.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Wallet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainTabs(), // 첫 화면을 탭 바가 있는 MainTabs로 설정
    );
  }
}

// 여기서부터 추가되는 탭 관리 클래스
class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ExpenseForm(),
    ExpenseList(),
    ExpenseChart(), // 1. 분석 화면 추가
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // 탭이 3개 이상일 때 스타일 고정
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '입력'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '내역'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: '분석'),
        ],
      ),
    );
  }
}
