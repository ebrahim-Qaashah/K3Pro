enum SensorCommand {
  getID('GetID'),
  getName('GetName'),
  getValue('GetVal');

  final String command;
  const SensorCommand(this.command);

  @override
  String toString() => command;
}
