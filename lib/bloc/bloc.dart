// Define events, state, and bloc
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart'; // Import meta for @immutable annotation

abstract class SettingsEvent {}

class SettingsChangeEvent extends SettingsEvent {}

enum Sentiment { positive, neutral, negative }

enum Feed {
  latestNews(category: 0),
  asiaNews(category: 6511),
  businessNews(category: 6936),
  singaporeNews(category: 10416),
  sportsNews(category: 10296),
  worldNews(category: 6311);

  const Feed({required this.category});
  final int category;
  get getCategory => category;
}

class SettingsState {
  final Map<String, Object> settings;
  SettingsState(this.settings);
}

class UpdateFeedsEvent extends SettingsEvent {
  final List<Feed> selectedFeeds;

  UpdateFeedsEvent(this.selectedFeeds);
}

class SettingsBloc extends Bloc<SettingsChangeEvent, SettingsState> {
  static const Map<String, Object> defaultSettings = {
    "feeds": [Feed.latestNews],
    "sentimentMinimum": Sentiment.positive
  };

  SettingsBloc() : super(SettingsState(defaultSettings));

  // Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
  //   if (event is SettingsChangeEvent) {
  //     yield SettingsState(state.settings);
  //   }
  // }
  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsChangeEvent) {
      yield state; // No change, just emit the current state
    } else if (event is UpdateFeedsEvent) {
      final updatedSettings = Map<String, Object>.from(state.settings);
      updatedSettings["feeds"] = event.selectedFeeds;
      yield SettingsState(updatedSettings);
    }
  }
}
