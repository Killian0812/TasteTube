import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart' as log;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/injection.dart';

class GetstreamCubit extends Cubit<GetstreamState> {
  GetstreamCubit() : super(GetstreamInitial());
  final log.Logger logger = getIt<log.Logger>();
  StreamChatClient? get client =>
      state is GetstreamSuccess ? (state as GetstreamSuccess).client : null;

  Future<void> initializeClient(AuthData userData, String streamToken) async {
    emit(GetstreamLoading());

    try {
      final client = StreamChatClient(
        'cd5kkff8cewb',
        logLevel: Level.OFF,
      );

      final user = await client.connectUser(
        User(
          id: userData.userId,
          name: userData.username,
          image: userData.image,
        ),
        streamToken,
      );

      logger.i('Stream User connected: $user');
      emit(GetstreamSuccess(client));
    } catch (e) {
      emit(GetstreamFailure('Failed to initialize Stream client: $e'));
    }
  }
}

abstract class GetstreamEvent {}

class InitializeStreamClient extends GetstreamEvent {
  final String userId;
  final String streamToken;

  InitializeStreamClient(this.userId, this.streamToken);
}

abstract class GetstreamState {}

class GetstreamInitial extends GetstreamState {}

class GetstreamLoading extends GetstreamState {}

class GetstreamSuccess extends GetstreamState {
  final StreamChatClient client;

  GetstreamSuccess(this.client);
}

class GetstreamFailure extends GetstreamState {
  final String error;

  GetstreamFailure(this.error);
}
