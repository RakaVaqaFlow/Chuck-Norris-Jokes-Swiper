import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';

import 'dart:convert';

import 'liked_screen.dart';
import 'about_screen.dart';
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String currentJoke = "";
  String currentImageLink = "";
  String nextJoke ="";
  String nextImageLink ="";
  List<String> images = [];
  final Set<String> _likedJokes = {};
  bool _isLoadingImagesComplete = false;

  Future<void> _loadNewJoke() async {
    final response = await http.get(Uri.parse('https://api.chucknorris.io/jokes/random'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final newJoke = responseData['value'].toString();
      setState(() {
        currentJoke = nextJoke;
        nextJoke = newJoke;
      });
    } else {
      throw Exception('Failed to load joke');
    }
  }

  Future<void> _loadImages() async{
    var url =
        'https://contextualwebsearch-websearch-v1.p.rapidapi.com/api/Search/ImageSearchAPI?q=Chuck%20Norris&pageNumber=1&pageSize=50&autoCorrect=true';
    var headers = {
    'X-RapidAPI-Key': 'edc7708318msh967901fc196befep1dd88ajsnf955564e482d',
      'X-RapidAPI-Host': 'contextualwebsearch-websearch-v1.p.rapidapi.com'
    };
    var r = await Requests.get(url, headers: headers);
    r.raiseForStatus();
    dynamic jsonBody = r.json();
    List<String> imagesList = [];
    for (var val in jsonBody['value']) {
      imagesList.add(val['url']);
    }
    setState(() {
      images = imagesList;
      _isLoadingImagesComplete = true;
    });
  }

  void _UpdateImage(){
    String newLink = "";
    if (!_isLoadingImagesComplete){
      newLink = "https://static.outsider.com/uploads/2022/11/chuck-norris-honors-late-walker-texas-ranger-costar-emotional-tribute.png";
    }
    else{
      int rndIndex = Random().nextInt(images.length);
      newLink = images[rndIndex];
    }

    setState(() {
        currentImageLink = nextImageLink;
        nextImageLink = newLink;
    });
  }

  void _loadDataFromNewCard(){
    _loadNewJoke();
    _UpdateImage();
  }

  void _likeJoke() {
    _loadDataFromNewCard();
    setState(() {
      _likedJokes.add(currentJoke);
    });
  }

  void _dislikeJoke() {
    _loadDataFromNewCard();
  }

  void _viewLikedJokes() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LikedScreen(likedJokes: _likedJokes.toList())),
    );
  }

  void _viewAboutScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
    _loadDataFromNewCard();
    setState(() {
      currentJoke = nextJoke;
      currentImageLink = nextImageLink;
    });
    _loadDataFromNewCard();
  }

  @override
  Widget build(BuildContext context) {
    _loadImages();
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () { /* Write listener code here */ },
            child: IconButton(
              color: Color(0xFF7080D7),
              icon: const Icon(Icons.settings),
              tooltip: 'Go to the next page',
              onPressed: _viewAboutScreen,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30.0),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF72326a),
                  Color(0xFF321c53),
                ],
              ),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30.0),
            ),
          ),
          backgroundColor: const Color(0xFFfef1ee),
          actions: <Widget>[
            IconButton(
              color: Color(0xFF7080D7),
              icon: const Icon(Icons.favorite_border),
              tooltip: 'Go to the next page',
              onPressed: _viewLikedJokes,
            ),
          ]
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isLoadingImagesComplete) {
      return Center(child: CircularProgressIndicator());
    } else {
      return _buildCards();
    }
  }

  Widget _buildCards() {
    if (!_isLoadingImagesComplete) {
      return Center(
        child: Text(
          'No more jokes!',
          style: TextStyle(fontSize: 24),
        ),
      );
    }
    else {
      return Container(
          color: Color(0xFF72326a),
          child: Stack(
          children: [LayoutBuilder(
            builder: (context, constraints) =>
                Draggable(
                  onDragEnd: (details) =>
                      evaluateSwipe(details),
                  feedback: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: _buildCard(
                          currentJoke, currentImageLink)
                  ),
                  childWhenDragging: _buildCard(nextJoke, nextImageLink),
                  child: _buildCard(currentJoke, currentImageLink),
                ),
          ),
          ]
      ),
      );
    }
  }


  Widget _buildCard(String joke, String imgSrc) {
    return Card(
      color: Color(0xffe8d9e2),
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                imgSrc,
                height: 200,
              ),
              SizedBox(height: 16),
              Text(
                joke,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
              Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.thumb_down),
                    onPressed: () => _dislikeJoke(),
                  ),
                  IconButton(
                    color: Colors.green,
                    icon: Icon(Icons.thumb_up),
                    onPressed: () => _likeJoke(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  void evaluateSwipe(DraggableDetails details) {
    if (details.offset.dx > 0) {
      _likeJoke();
    } else if (details.offset.dx < 0) {
      _dislikeJoke();
    }
  }


}