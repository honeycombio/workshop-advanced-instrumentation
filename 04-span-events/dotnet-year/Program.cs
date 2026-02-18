using System.Diagnostics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var years = new[] { 2015, 2016, 2017, 2018, 2019, 2020 };
var random = new Random();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService("dotnet-year"))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddSource("dotnet-year")
        .AddOtlpExporter());

var app = builder.Build();

var tracer = new ActivitySource("dotnet-year");

app.MapGet("/", () => Results.Content("service: <a href='/year'>/year</a>", "text/html"));

app.MapGet("/year", (HttpContext ctx) =>
{
    Thread.Sleep(random.Next(250));
    var parentContext = Activity.Current?.Context ?? default;
    _ = Task.Run(() => DoSomeWork(parentContext));
    var year = GetYear();
    var span = Activity.Current;
    span?.SetTag("foo", "bar");
    return Results.Json(new
    {
        language = "dotnet",
        year,
        generated = DateTime.UtcNow
    });
});

void DoSomeWork(ActivityContext parentContext)
{
    using var span = tracer.StartActivity("some-work", ActivityKind.Internal, parentContext);
    span?.SetTag("otel", "rocks");
    Thread.Sleep(random.Next(250));
    // add span event
    span?.AddEvent(new ActivityEvent("my event", tags: new ActivityTagsCollection { ["more"] = "details" }));
    Thread.Sleep(random.Next(150) + 100);
    span?.AddEvent(new ActivityEvent("another event"));
}

int GetYear()
{
    using var span = tracer.StartActivity("getYear");
    var rnd = random.Next(years.Length);
    var year = years[rnd];
    span?.SetTag("random-index", rnd);
    span?.SetTag("year", year);
    Thread.Sleep(random.Next(250));
    return year;
}

app.Run("http://0.0.0.0:6001");
