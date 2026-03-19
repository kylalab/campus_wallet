import 'package:flutter/material.dart';
import 'db_helper.dart';

class ExpenseList extends StatefulWidget {
  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _refreshExpenses(); // 화면 시작 시 데이터 불러오기
  }

  // expense_list.dart 파일 내 수정
  void _refreshExpenses() async {
    final data = await DBHelper().getExpenses();
    setState(() {
      _expenses = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지출 내역'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshExpenses)
        ],
      ),
      body: _expenses.isEmpty
          ? Center(child: Text('입력된 내역이 없습니다.'))
          :
          ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final item = _expenses[index];
                final id = item['id'] as int; // 삭제를 위해 id 저장

                return Dismissible(
                  key: Key(id.toString()), // 각 항목을 식별할 고유 키
                  direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로 밀 때만 삭제
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    final targetId = id; // 삭제할 ID 미리 확보

                    // 1. DB에서 먼저 삭제
                    await DBHelper().deleteExpense(targetId);

                    // 2. 그 다음 UI 리스트에서 제거
                    setState(() {
                      _expenses.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('내역이 삭제되었습니다.')),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(item['category'][0])),
                      title: Text('${item['amount']}원'),
                      subtitle: Text('${item['memo']}'),
                      trailing: Text(item['date'].toString().split('T')[0]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
