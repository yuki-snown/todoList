import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

final _fname ='mydata.txt';
// テキストフィールドを管理するコントローラを作成(入力内容の取得用)
final textController = TextEditingController();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'サンプルアプリ',
      theme: new ThemeData.dark(),
      debugShowCheckedModeBanner: false, // これを追加するだけ
      home: InputDataForm(),
    );
  }
}

class InputDataForm extends StatefulWidget {
  @override
  _InputDataFormState createState() => _InputDataFormState();
}

class _InputDataFormState extends State {
  // 入力データ格納用のリスト
  List<Map<String, dynamic>> items = [];

  Future<File> getDataFile() async {
    final dir = await getApplicationDocumentsDirectory();    
    return File(dir.path + '/' + _fname);  
  }
  void saveIt() async{
    String value="";
    getDataFile().then((File file){
      for(int i=0; i<items.length;i++){
        value = "${value}" + "${items[i]["content"]}" + ',';
      }
      file.writeAsString(value);
    });
  }
  void loadIt() async {
    getDataFile().then((File file){
      file.readAsString().then((String contents) {
      String cash = "";
      int j=1;
      if(contents!=null){
        for(int i=0;i<contents.length;i++){
          if(contents[i]!=","){
            cash = "${cash}" + "${contents[i]}";
          }
          else {
            setState(() {
              items.add({ "id": j, "content": cash});
            });
            j++;
            cash ="";
          }
        }
      }
      return null;
      });
    });
  }

  //　ID（カウンタ変数）
  int _counter = 0;

  //　追加ボタンが押されたときの処理（リストにIDと入力データを新規追加）
  void _addItem(String inputText) {
    setState(() {
      _counter++;
      items.add({ "id": _counter, "content": inputText});
    });
  }

  @override
  // widgetの破棄時にコントローラも破棄
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void delete(int index) {
    items.removeAt(index);
    _counter -= 1;
    for(int i=0; i<items.length;i++){
      items[i]["id"] = i+1;
    }
  }

   //ここが重要
  @override
  void initState(){
    //アプリ起動時に一度だけ実行される
    loadIt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do',
          style: TextStyle(fontSize:32.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFamily: "Roboto"),
        ),
      ),
      body: Container (
        child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(8.0),),
              Text("タスクを追加",
                style: TextStyle(fontSize:21.0,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: "Roboto"),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: textController,
                ),
              ),
              Expanded(
                child:ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = items[index];
                      // 新しいカードを作成して返す
                      return new Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.assignment,
                            color: Colors.white,
                            size: 36.0),
                          title: Text(item["id"].toString() + " : " + item["content"],
                            style: TextStyle(fontSize:28.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Roboto"),
                          ),
                          trailing: Icon(
                            Icons.delete_sweep,
                            color: Colors.white,
                            size: 36.0
                            ),
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text(" - WARNING - "),
                                  content: Text("タスクを消去しますか?"),
                                  actions: <Widget>[
                                  FlatButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    } ,
                                    ),
                                  FlatButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      setState(() {
                                      delete(index);                                        
                                      });
                                      saveIt();
                                      Navigator.pop(context);                                     
                                    }
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    }),
              ),
            ]),
      ),
      // テキストフィールド送信用ボタン
      floatingActionButton: FloatingActionButton(
        // ボタンが押された時の動作
        onPressed: () {
          //テキストフィールドの内容を取得し、アイテムリストに追加
          if (textController.text != ""){
            _addItem(textController.text);
          }
          // テキストフィールドの内容をクリア
          textController.clear();
          saveIt();
        },
        backgroundColor: const Color(0xFFf0e8e8),
        child: Icon(Icons.add),
      ),
    );
  }
}