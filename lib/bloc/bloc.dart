// Define events, state, and bloc
import 'package:bloc/bloc.dart';

abstract class SettingsEvent {}

class SettingsChangeEvent extends SettingsEvent {}
enum Sentiment { positive, neutral, negative }
enum Feed { latestNews(category: 0), asiaNews(category: 6511), businessNews(category: 6936), singaporeNews(category: 10416), sportsNews(category: 10296), worldNews(category: 6311);
  const Feed ({required this.category});
  final int category;
  get getCategory => category;
}

class SettingsState {
  var settings = {
    "feeds": [
      Feed.latestNews
    ],
    "sentimentMinimum": Sentiment.positive
  };

  SettingsState(this.settings);
}

class SettingsBloc extends Bloc<SettingsChangeEvent, SettingsState> {
  static const Map<String, Object> defaultSettings = {
    "feeds": [
      Feed.latestNews
    ],
    "sentimentMinimum": Sentiment.positive
  };

  SettingsBloc() : super(SettingsState(defaultSettings));

  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsChangeEvent) {
      yield SettingsState(state.settings);
    }
  }
}
