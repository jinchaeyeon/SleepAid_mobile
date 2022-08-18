import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:sleepaid/bluetooth/flutter_reactive_ble/reactive_state.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  String connectedDeviceId = "";
  String connectedDeviceName = "";

  BleDeviceConnector({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>.broadcast();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate> connection;

  Future<void> connect(String deviceId, String deviceName) async {
    _logMessage('Start connecting to $deviceId');
    connection = _ble.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 25)
    ).listen(
          (update) {
        connectedDeviceId = deviceId;
        connectedDeviceName = deviceName;
        _logMessage(
            '==== ConnectionState for device $deviceId : ${update.connectionState}');
        _deviceConnectionController.add(update);
      },
      onError: (Object e){
        _logMessage('==== Connecting to device $deviceId resulted in error $e');
        connectedDeviceId = "";
        connectedDeviceName = "";
      }
    );
  }

  Future<void> disconnect(String deviceId) async {
    connectedDeviceId = "";
    connectedDeviceName = "";
    try {
      _logMessage('disconnecting to device: $deviceId');
      await connection?.cancel();
    } on Exception catch (e, _) {
      _logMessage("Error disconnecting from a device: $e");
    } finally {
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }

  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }

  void init() {
    connectedDeviceId = "";
    connectedDeviceName = "";
  }
}