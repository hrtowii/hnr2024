// Define events, state, and bloc
import 'package:bloc/bloc.dart';

abstract class SettingsEvent {}

class SettingsChangeEvent extends SettingsEvent {}
enum Sentiment { positive, neutral, negative }
class SettingsState {
  var settings = {
    "feeds": [
      ""
    ],
    "sentimentMinimum": Sentiment.positive
  };

  SettingsState(this.settings);
}

class SettingsBloc extends Bloc<SettingsChangeEvent, SettingsState> {
  static const Map<String, Object> defaultSettings = {
    "feeds": [
      "https://www.channelnewsasia.com/api/v1/rss-outbound-feed?_format=xml&category=6511"
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
