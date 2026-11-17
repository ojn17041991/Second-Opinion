## Setup
1. Set `Worker:ServiceBus:Topic` and `Worker:ServiceBus:Subscription` in `appsettings.json` and `appsettings.Development.json`.
2. Implement a message handler that inherits `BaseMessageHandler<T>`.
3. Register the message handler in `Program.cs` using `IMessageHandler`.