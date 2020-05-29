import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List data;
  String next;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Expanded(
          child: NotificationListener(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  // start loading data
                  setState(() {
                    isLoading = true;
                  });
                  _loadData();
                }
              },
              child: _buildListView()),
        ),
        Container(
          height: isLoading ? 50.0 : 0,
          color: Colors.transparent,
          child: Center(
            child: new CircularProgressIndicator(),
          ),
        ),
      ]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (context, index) {
          return _buildImageColumn(data[index]);
        });
  }

  Widget _buildImageColumn(item) {
    RegExp exp = new RegExp(r'https://pokeapi.co/api/v2/pokemon-species/(\d+)');
    String str = item['url'];
    final match = exp.firstMatch(str);
    String num = match.group(1).padLeft(3, '0');
    return Container(
        child: Column(
      children: <Widget>[
        _sizedContainer(
          CachedNetworkImage(
            imageUrl:
                'https://assets.pokemon.com/assets/cms2/img/pokedex/full/$num.png',
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        ListTile(
          title: Text(item['name']),
        ),
      ],
    ));
  }

  Widget _sizedContainer(Widget child) {
    return SizedBox(
      width: 150.0,
      height: 150.0,
      child: Center(child: child),
    );
  }

  @override
  void initState() {
    super.initState();
    this.getListPkm();
  }

  Future<String> getListPkm() async {
    var url = 'https://pokeapi.co/api/v2/pokemon-species';

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        data = jsonResponse['results'];
        next = jsonResponse['next'];
      });
      return 'success';
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future _loadData() async {
    var response = await http.get(next);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        data.addAll(jsonResponse['results']);
        next = jsonResponse['next'];
        isLoading = false;
      });
      return 'success';
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
