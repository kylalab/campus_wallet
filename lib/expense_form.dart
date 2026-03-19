import 'package:flutter/material.dart';
import 'db_helper.dart';

class ExpenseForm extends StatefulWidget {
  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  String _selectedCategory = '식비';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['식비', '교통비', '쇼핑', '문화생활', '기타'];

  void _saveExpense() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('올바른 금액을 입력해주세요.')),
      );
      return;
    }

    // DB 데이터 구조에 맞춰 Map 생성
    Map<String, dynamic> row = {
      'amount': amount,
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String(),
      'memo': _memoController.text,
    };

    final id = await DBHelper().insertExpense(row);
    print('저장된 데이터 ID: $id');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('지출 내역이 저장되었습니다!')),
    );

    // 저장 후 입력창 초기화
    _amountController.clear();
    _memoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('지출 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: '금액 (원)', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedCategory = val as String),
              decoration: InputDecoration(
                  labelText: '카테고리', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            // expense_form.dart 의 ListTile 부분 수정
            ListTile(
              // Text 부분을 수정하여 현재 선택된 날짜를 보여줍니다.
              title: Text("날짜: ${_selectedDate.year}-"
                  "${_selectedDate.month.toString().padLeft(2, '0')}-" // 월이 1자리일 때 앞에 '0' 추가
                  "${_selectedDate.day.toString().padLeft(2, '0')}" // 일이 1자리일 때 앞에 '0' 추가
                  ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked; // 선택한 날짜로 상태 업데이트
                  });
                }
              },
            ),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                  labelText: '메모 (선택사항)', border: OutlineInputBorder()),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text('저장하기'),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
