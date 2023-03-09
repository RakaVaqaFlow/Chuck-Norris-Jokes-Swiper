import 'package:flutter/material.dart';

class LikedScreen extends StatelessWidget {
  final List<String> likedJokes;

  LikedScreen({required this.likedJokes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: ListView.builder(
        itemCount: likedJokes.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(likedJokes[index]),
            ),
          );
        },
      ),
    );
  }
}