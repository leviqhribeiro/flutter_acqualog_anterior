
import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/resources/user_api_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';


enum PushNotificationsBlocEvent {
  registerForNotifications,
  newNotification,
  clearReceivedNotification
}

class PushNotificationsBloc extends Bloc<BlocEvent<PushNotificationsBlocEvent>,
    PushNotificationsBlocState> {
  PushNotificationsBloc(PushNotificationsBlocState initialState)
      : super(initialState);

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _userApiProvider = const UserApiProvider();

  @override
  Stream<PushNotificationsBlocState> mapEventToState(
      BlocEvent<PushNotificationsBlocEvent> event) async* {
    switch (event.event) {
      case PushNotificationsBlocEvent.registerForNotifications:
        if (!state.isRegisteredForNotifications) {
          yield await _registerForNotifications();
        } else {
          yield state;
        }
        break;
      case PushNotificationsBlocEvent.newNotification:
        final newState = PushNotificationsBlocState.fromState(state);
        newState.receivedNotif = NotificationData(event.data['message']);
        newState.receivedNotifKind = event.data['kind'];
        yield newState;
        break;
      case PushNotificationsBlocEvent.clearReceivedNotification:
        final newState = PushNotificationsBlocState.fromState(state);
        newState.receivedNotif = null;
        newState.receivedNotifKind = ReceivedNotifKind.none;
        yield newState;
        break;
    }
  }

  bool isMissionOfNotif(String missionId) {
    return state.receivedNotif?.missionId == missionId;
  }

  void _fireEventNewNotif(
      Map<String, dynamic> message, ReceivedNotifKind kind) {
    final data = {
      'message': message,
      'kind': kind,
    };
    add(BlocEvent(PushNotificationsBlocEvent.newNotification, data: data));
  }

  Future<PushNotificationsBlocState> _registerForNotifications() async {
    RemoteMessage message = await FirebaseMessaging.instance
        .getInitialMessage();
    if (message != null) {
      print('Message tapped and opened the app from terminated');
      _fireEventNewNotif(message.data, ReceivedNotifKind.onMessageOpenedAppFromTerminated);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      HapticFeedback.vibrate().then(
              (value) => _fireEventNewNotif(message.data, ReceivedNotifKind.onMessage));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message tapped and opened the app from background, app not terminated');
      _fireEventNewNotif(message.data, ReceivedNotifKind.onMessageOpenedAppFromBackground);
    });

    final newState = PushNotificationsBlocState.fromState(state);

    NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
    if(settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings =
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    if(settings != null) {
      final isPermitted = [
        AuthorizationStatus.authorized,
        AuthorizationStatus.provisional
      ].contains(settings.authorizationStatus);

      if (isPermitted) {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          try {
            await _userApiProvider.updateDeviceToken(deviceId: token);
          } catch (e) {
            print(e.toString());
          }
          print('Push Messaging token: $token');
        }
      }
      else {
        final isDenied = AuthorizationStatus.denied == settings.authorizationStatus;
        newState.showFixNotifPermissionAlert = isDenied;
      }
    }

    newState.isRegisteredForNotifications = true;

    return newState;

  }
}

class PushNotificationsBlocState {
  PushNotificationsBlocState();

  PushNotificationsBlocState.fromState(PushNotificationsBlocState state) {
    isRegisteredForNotifications = state.isRegisteredForNotifications;
    showFixNotifPermissionAlert = state.showFixNotifPermissionAlert;
    receivedNotif = state.receivedNotif;
    receivedNotifKind = state.receivedNotifKind;
  }

  bool showFixNotifPermissionAlert;
  bool isRegisteredForNotifications = false;
  NotificationData receivedNotif;
  ReceivedNotifKind receivedNotifKind = ReceivedNotifKind.none;
}

enum ReceivedNotifKind { onMessage, onMessageOpenedAppFromBackground,onMessageOpenedAppFromTerminated,none }

class NotificationData {
  NotificationData(Map<String, dynamic> message)
      : _message = message,
        _messageData = Map<String, dynamic>.from(message['data'] ?? message);

  final Map<String, dynamic> _message;
  final Map<String, dynamic> _messageData;
  String get type => _messageData['type']; //NotificationType
  String get missionId => _messageData['id'];
}

class NotificationType {
  static final newMission = 'newMission';
  static final missionUpdate = 'missionUpdate';
}

