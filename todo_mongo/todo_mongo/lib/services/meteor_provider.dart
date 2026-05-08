import 'package:dart_meteor/dart_meteor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meteor_provider.g.dart';

@Riverpod(keepAlive: true)
MeteorClient meteorClient(Ref ref) {
  final client = MeteorClient.connect(url: 'ws://10.0.2.2:3000/websocket');
  
  ref.onDispose(() {
    client.disconnect();
  });
  
  return client;
}