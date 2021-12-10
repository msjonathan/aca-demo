
using Azure.Messaging.ServiceBus;

// this is a test  project, no validation is done
var connectionString = Environment.GetCommandLineArgs()[1];
var queueName = Environment.GetCommandLineArgs()[2];
var nrOfMessage = Environment.GetCommandLineArgs()[3];

Console.WriteLine($"Sending {nrOfMessage} to {queueName} on {connectionString}");
await using var client = new ServiceBusClient(connectionString);

ServiceBusSender sender = client.CreateSender(queueName);
IList<ServiceBusMessage> messagesToSend = new List<ServiceBusMessage>();

for (int i = 0; i <  Convert.ToInt32(nrOfMessage); i++)
{
    messagesToSend.Add(new ServiceBusMessage($"message nr: {i}"));
}

await sender.SendMessagesAsync(messagesToSend);

Console.WriteLine("done sending");
Console.ReadKey();