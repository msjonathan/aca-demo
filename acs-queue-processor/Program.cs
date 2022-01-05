using Azure.Messaging.ServiceBus;

var connectionString = Environment.GetEnvironmentVariable("service-bus-connectionstring");
var queueName = Environment.GetEnvironmentVariable("queuename");

Console.WriteLine($"Creating processor for {queueName} on {connectionString}");
await using var client = new ServiceBusClient(connectionString);

var options = new ServiceBusProcessorOptions
{
    AutoCompleteMessages = false,
    MaxConcurrentCalls = 1
};

await using ServiceBusProcessor processor = client.CreateProcessor(queueName, options);

processor.ProcessMessageAsync += MessageHandler;
processor.ProcessErrorAsync += ErrorHandler;

async Task MessageHandler(ProcessMessageEventArgs args)
{
    string body = args.Message.Body.ToString();
    Console.WriteLine(body);
    await Task.Delay(TimeSpan.FromSeconds(1));
    // we can evaluate application logic and use that to determine how to settle the message.
    await args.CompleteMessageAsync(args.Message);
}
Task ErrorHandler(ProcessErrorEventArgs args)
{
    // the error source tells me at what point in the processing an error occurred
    Console.WriteLine(args.ErrorSource);
    // the fully qualified namespace is available
    Console.WriteLine(args.FullyQualifiedNamespace);
    // as well as the entity path
    Console.WriteLine(args.EntityPath);
    Console.WriteLine(args.Exception.ToString());
    return Task.CompletedTask;
}

await processor.StartProcessingAsync();

while(CancellationToken.None.IsCancellationRequested != true)
{
    await Task.Delay(TimeSpan.FromSeconds(2));
}

