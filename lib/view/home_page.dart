import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gif_search/view/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? search;

  int offSet = 0;

  Future<Map> getGifs() async {
    http.Response response;

    if (search == "")
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=9i5Qgzf6GeGEmfcCqPHfl5BlydPKM3eS&limit=20&rating=g"));
    else
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=9i5Qgzf6GeGEmfcCqPHfl5BlydPKM3eS&q=$search&limit=19&offset=$offSet&rating=g&lang=en"));

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  search = text;
                  offSet = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return createGifTable(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int getCount(List data) {
    if (search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (search == null || index < snapshot.data["data"].length)
          return GestureDetector(
            child: Image.network(
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GifPage(gifData: snapshot.data["data"][index])),
              );
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    "Carregar mais ...",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  offSet += 19;
                });
              },
            ),
          );
      },
    );
  }
}
