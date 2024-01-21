// import 'dart:io';
// import 'dart:html';

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'bloc/bloc.dart';

class RSSDemo extends StatefulWidget {
  //
  const RSSDemo() : super();

  final String title = 'RSS Feed Demo';

  @override
  RSSDemoState createState() => RSSDemoState();
}

class RSSDemoState extends State<RSSDemo> {
  // TODO: make FEED_URL changed via settings
  final Uri FEED_URL = Uri.https('channelnewsasia.com',
      'api/v1/rss-outbound-feed?_format=xml&category=6511', {'limit': '10'});
  RssFeed _feed = RssFeed();
  String _title = "";
  static const String loadingFeedMsg = 'Loading Feed...';
  static const String feedLoadErrorMsg = 'Error Loading Feed.';
  static const String feedOpenErrorMsg = 'Error Opening Feed.';
  static const String placeholderImg = "https://placehold.co/600x400/png";
  late GlobalKey<RefreshIndicatorState> _refreshKey;

  updateTitle(title) {
    setState(() {
      if (_title != String) {
        _title = "Not found";
      }
      _title = title;
    });
  }

  updateFeed(feed) {
    setState(() {
      _feed = feed;
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    } else {
      updateTitle(feedOpenErrorMsg);
    }
  }

  load() async {
    updateTitle(loadingFeedMsg);
    loadFeed().then((result) {
      if (result.toString().isEmpty) {
        updateTitle(feedLoadErrorMsg);
        return;
      }
      updateFeed(result);
      updateTitle(_feed.title);
    });
  }

  Future<RssFeed?> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(FEED_URL);
      final object = RssFeed.parse(response.body);
      return object;
    } catch (e) {
      return RssFeed();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.title);
    load();
  }

  title(title) {
    if (title == null) {
      return const Text("Title not found");
    }
    return Text(
      title,
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  date(DateTime date, RssItem item, Rating sentiment) {
    Color textColor;
    var emoji = "";
    switch (sentiment.label) {
      case "POSITIVE":
        emoji = "🥰";
        textColor = Colors.green;
        break;
      case "NEGATIVE":
        emoji = "😭";
        textColor = Colors.red;
        break;
      default:
        emoji = "😐";
        textColor = Colors.black;
    }
    if (sentiment.score <= 0.85 &&
        sentiment.label.toLowerCase() != "negative") {
      return RichText(
        text: TextSpan(
          text: DateFormat("dd/MM hh:mm ").format(date),
          style: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: "\n${emoji + sentiment.label.toLowerCase()}" +
                  ", ${(sentiment.score.toDouble() * 100).toStringAsFixed(2)}% sure",
              style: TextStyle(
                color: textColor,
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Container();
    }
  }

  thumbnail(imageUrl) {
    if (imageUrl == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: CachedNetworkImage(
          placeholder: (context, url) => Image.network(placeholderImg),
          imageUrl: placeholderImg,
          height: 100,
          width: 90,
          alignment: Alignment.center,
          fit: BoxFit.fill,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: CachedNetworkImage(
          placeholder: (context, url) => Image.network(placeholderImg),
          imageUrl: imageUrl,
          height: 100,
          width: 90,
          alignment: Alignment.center,
          fit: BoxFit.fill,
        ),
      );
    }
  }

  rightIcon() {
    return const Icon(
      Icons.keyboard_arrow_right,
      color: Colors.grey,
      size: 30.0,
    );
  }

  Future<dynamic> fetchSentiments(item) async {
    try {
      var realdescription =
          await TextDescription.createTextDescription(item.link!);
      return await Rating.getRating(realdescription.news);
    } catch (error) {
      return const TextDescription(news: "Error loading description");
    }
  }

  list(Map<String, Object> settings) {
    return ListView.builder(
        itemCount: _feed.items?.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _feed.items![index];
          // if <insert preference> == true, return this. else, return the one without the if statement.
          return FutureBuilder<dynamic>(
              // asynchronously fetch the stuff and pass it down to date separately without double calling it in Date
              future: fetchSentiments(item),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(); // or a loading indicator
                } else if (snapshot.hasError) {
                  return Text(
                      'Error loading sentiment analysis: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  Rating sentiment = snapshot.data!;
                  if (sentiment.score <= 0.85 &&
                      sentiment.label.toLowerCase() != "negative") {
                    return ListTile(
                        title: title(item.title),
                        subtitle: date(item.pubDate!, item, sentiment),
                        leading: thumbnail(item.media!.thumbnails!.first
                            .url), // wtf man... why is this like this...
                        trailing: rightIcon(),
                        contentPadding: const EdgeInsets.all(5.0),
                        // onTap: () => openFeed(item.link!),
                        onTap: () async {
                          TextDescription description =
                              await TextDescription.createTextDescription(
                                  item.link!);
                          // TODO: move this to RSSModal.dart
                          showModalBottomSheet<void>(
                              // I have no idea how this thing fucking works, but this is from asking chatgpt and relying on flutter docs https://docs.flutter.dev/cookbook/networking/send-data
                              context: context,
                              builder: (BuildContext context) {
                                return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: SingleChildScrollView(
                                      child: SizedBox(
                                        height: 600,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Align(
                                                // aligns the text to top left
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  item.title ??
                                                      "Title not found...",
                                                  style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                            Text(
                                              description.news.isEmpty
                                                  ? item
                                                      .description! // fallback to RSS feed one if the server is dead
                                                  : description.news,
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const Spacer(),
                                            ElevatedButton(
                                              child: const Text('Back'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                            ElevatedButton(
                                                child: const Text(
                                                    'View article in browser'),
                                                onPressed: () => {
                                                      openFeed(item.link!),
                                                      Navigator.pop(context),
                                                    }),
                                          ],
                                          // ),
                                        ),
                                      ),
                                    ));
                              });
                        });
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              });
        });
  }

  isFeedEmpty() {
    return null == _feed || null == _feed.items;
  }

  body(Map<String, Object> settings) {
    return isFeedEmpty()
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: list(settings),
            onRefresh: () => load(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: body(settingsState.settings),
      );
    });
  }
}

class TextDescription {
  final String news;

  const TextDescription({required this.news});

  factory TextDescription.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'news': String news,
      } =>
        TextDescription(news: news),
      _ => throw const FormatException('Failed to load textdescription.'),
    };
  }
  static Future<TextDescription> createTextDescription(String url) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/scrape'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'url': url,
      }),
    );

    if (response.statusCode == 200) {
      return TextDescription.fromJson(jsonDecode(response.body)
          as Map<String, dynamic>); // chatgpt I LOVE YOU SO MUCH
    } else {
      throw Exception('Failed to create text description.');
    }
  }
}

// thx to YY
class Rating {
  final String label;
  final double score;

  Rating({required this.label, required this.score});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      label: json['label'] as String,
      score: json['score'] as double,
    );
  }

  static Future<Rating> getRating(String input) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/analyse'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': input,
      }),
    );

    if (response.statusCode == 200) {
      return Rating.fromJson(jsonDecode(response.body));
    } else {
      throw Exception();
    }
  }
}
