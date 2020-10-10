import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[200],
      appBar: AppBar(
        title: Text("Recipe Finder"),
      ),
      body: MianScreen(),
    );
  }
}

class MianScreen extends StatefulWidget {
  @override
  _MianScreenState createState() => _MianScreenState();
}

class _MianScreenState extends State<MianScreen> {
  int _itemCount = 0;
  var jsonResponse;
  var jsonIngredients;
  String _Query;

  Future<void> getQuotes(query) async {
    String url = "http://10.0.2.2:5000/?query=$query";
    http.Response response = await http.get(url);
    var responsejson;
    if (response.statusCode == 200) {
      setState(() {
        responsejson = convert.jsonDecode(response.body);
        jsonResponse = responsejson["results"];

        _itemCount = responsejson["results"].length;
      });

      print("Number of recipes found : $_itemCount.");
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "search for a recipe ",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    onChanged: (value) {
                      _Query = value;
                      print(value);
                    },
                  ),
                  ButtonTheme(
                    minWidth: 100,
                    child: RaisedButton(
                      child: Text(
                        "get recipes",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.black87,
                      onPressed: () {
                        getQuotes(_Query);
                        setState(() {
                          _itemCount = 0;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: _itemCount == 0 ? 50 : 350,
              child: _itemCount == 0
                  ? CircularProgressIndicator()
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 10),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  jsonResponse[index]["title"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ),
                              InkWell(
                                  onTap: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Recipe & Ingredients'),
                                          content: setupAlertDialoadContainer(
                                              jsonResponse[index]
                                                  ["missedIngredientCount"],
                                              index,
                                              jsonResponse[index][
                                                          "analyzedInstructions"]
                                                      [0]["steps"]
                                                  .length),
                                        );
                                      }),
                                  child: Image.network(
                                      jsonResponse[index]["image"])),
                            ],
                          ),
                        );
                      },
                      itemCount: _itemCount,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget setupAlertDialoadContainer(
    int ingredientcount,
    int ingredientIndex,
    int recipeStepsCount,
  ) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL, // default
      front: Container(
        height: 600.0,
        width: 400.0,
        child: ingredientcount == 0
            ? CircularProgressIndicator()
            : ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            jsonResponse[ingredientIndex]["missedIngredients"]
                                [index]["original"],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        Image.network(jsonResponse[ingredientIndex]
                            ["missedIngredients"][index]["image"]),
                      ],
                    ),
                  );
                },
                itemCount: ingredientcount,
              ),
      ),
      back: Container(
        height: 600.0,
        width: 400.0,
        child: recipeStepsCount == 0
            ? CircularProgressIndicator()
            : ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            jsonResponse[ingredientIndex]
                                        ["analyzedInstructions"][0]["steps"]
                                    [index]["number"]
                                .toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        Text(
                          jsonResponse[ingredientIndex]["analyzedInstructions"]
                              [0]["steps"][index]["step"],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: recipeStepsCount,
              ),
      ),
    );
  }
}
