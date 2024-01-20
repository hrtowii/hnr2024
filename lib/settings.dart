// Use BlocBuilder to consume the bloc
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bloc.dart' as settings_bloc;
import 'bloc/bloc.dart';

class Settings extends StatefulWidget {
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  List<Feed> selectedFeeds = [];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<settings_bloc.SettingsBloc, settings_bloc.SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: Feed.values
                  .map((feed) => FeedCheckbox(
                        feed: feed,
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              selectedFeeds.add(feed);
                            } else {
                              selectedFeeds.remove(feed);
                            }
                          });
                        },
                      ))
                  .toList(),
              // children: <Widget>[
              //   Text(
              //     'Settings',
              //   ),
              //   Text(
              //     state.settings.toString(),
              //     style: Theme.of(context).textTheme.headline4,
              //   ),
              // ],
            ),
          ),
        );
      },
    );
  }
}

class FeedCheckbox extends StatefulWidget {
  final Feed feed;
  final ValueChanged<bool?> onChanged;

  const FeedCheckbox({Key? key, required this.feed, required this.onChanged})
      : super(key: key);

  @override
  _FeedCheckboxState createState() => _FeedCheckboxState();
}

class _FeedCheckboxState extends State<FeedCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(getFeedDisplayName(widget.feed)),
      value: isChecked,
      onChanged: (value) {
        setState(() {
          isChecked = value!;
          widget.onChanged(value);
          print(value);
        });
      },
    );
  }

  String getFeedDisplayName(Feed feed) {
    switch (feed) {
      case Feed.latestNews:
        return 'Latest News';
      case Feed.asiaNews:
        return 'Asia News';
      case Feed.businessNews:
        return 'Business News';
      case Feed.singaporeNews:
        return 'Singapore News';
      case Feed.sportsNews:
        return 'Sports News';
      case Feed.worldNews:
        return 'World News';
    }
  }
}
