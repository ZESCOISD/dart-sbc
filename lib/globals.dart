import 'dart:io';
import 'package:dart_pbx/handlers/requests_handlers.dart';
import 'package:dart_pbx/services/models/gateway.dart' as gw;
import 'package:dart_pbx/sip_parser/sip.dart';

WebSocket? webSocket;
typedef SipMessage = SipMsg;
Map<String, gw.Gateway> gateways = {};

RequestsHandler requestsHander = RequestsHandler();
