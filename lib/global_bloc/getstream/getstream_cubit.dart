import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart' as log;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/core/fcm_service.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/core/injection.dart';

final streamClient = StreamChatClient(
  'cd5kkff8cewb',
  logLevel: Level.OFF,
);

class GetstreamCubit extends Cubit<GetstreamState> {
  GetstreamCubit() : super(GetstreamLoading());

  final log.Logger logger = getIt<log.Logger>();

  Future<void> initializeClient(AuthData userData) async {
    emit(GetstreamLoading());

    try {
      final currentUser = streamClient.state.currentUser;
      if (currentUser?.id == userData.userId && userData.role != "ADMIN") {
        logger.i(
            'Stream User already connected: ${streamClient.state.currentUser}');
        emit(GetstreamSuccess());
        return;
      }

      if (currentUser != null) {
        await streamClient.disconnectUser(flushChatPersistence: true);
      }

      final user = await streamClient.connectUser(
        userData.role == "ADMIN"
            ? User(
                id: "TasteTube_Admin",
                name: "TasteTube Assistant",
                image:
                    "https://firebasestorage.googleapis.com/v0/b/taste-tube.appspot.com/o/tastetube_v2.png?alt=media&token=b77dce85-185a-4c0c-bfa9-965fe8e4aa78",
              )
            : User(
                id: userData.userId,
                name: userData.username,
                image: userData.image,
              ),
        userData.streamToken,
      );

      FCMService.updateStreamFcmToken();

      logger.i('Stream User connected: $user');
      emit(GetstreamSuccess());
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

class GetstreamLoading extends GetstreamState {}

class GetstreamSuccess extends GetstreamState {
  GetstreamSuccess();
}

class GetstreamFailure extends GetstreamState {
  final String error;

  GetstreamFailure(this.error);
}
