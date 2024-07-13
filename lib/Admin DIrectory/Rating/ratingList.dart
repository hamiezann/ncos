import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ncos/Admin%20DIrectory/Rating/ratingModel.dart';
import '../../Network Configuration/networkConfig.dart';
import 'package:intl/intl.dart';

class AdminRatingListPage extends StatefulWidget {
  const AdminRatingListPage({Key? key}) : super(key: key);

  @override
  State<AdminRatingListPage> createState() => _AdminRatingListPageState();
}

class _AdminRatingListPageState extends State<AdminRatingListPage> {
  late Future<List<Rating>> futureRatings;

  @override
  void initState() {
    super.initState();
    futureRatings = fetchRatings();
  }

  Future<List<Rating>> fetchRatings() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/ratings-list'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((rating) => Rating.fromJson(rating)).toList();
    } else {
      throw Exception('Failed to load ratings');
    }
  }

  Future<void> _refreshRatingList() async {
    setState(() {
      futureRatings = fetchRatings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ratings'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRatingList,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.red.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FutureBuilder<List<Rating>>(
            future: futureRatings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No ratings found'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Rating rating = snapshot.data![index];
                    return SingleChildScrollView(
                        child: RatingCard(rating: rating));
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class RatingCard extends StatelessWidget {
  final Rating rating;

  RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('URL_TO_PROFILE_IMAGE'),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ID: ${rating.userId}', // Replace with actual username
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${DateFormat.yMMMd().format(rating.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index <rating.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size:20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              rating.description ?? 'No descrition',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: #${rating.orderId}',
                  style: TextStyle( fontSize: 12,color: Colors.grey,),
                ),
                Icon(
                  Icons.favorite_border,
                  color: Colors.grey,
                  size: 20,
                )
              ],
            )

          ],
        ),
      ),
    );
  }
}
