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
    // pass context so async work is linked to current trace
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
