using System.Net.Http.Json;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var namesByYear = new Dictionary<int, string[]>
{
    [2015] = new[] { "sophia", "jackson", "emma", "aiden", "olivia", "liam", "ava", "lucas", "mia", "noah" },
    [2016] = new[] { "sophia", "jackson", "emma", "aiden", "olivia", "lucas", "ava", "liam", "mia", "noah" },
    [2017] = new[] { "sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "lucas" },
    [2018] = new[] { "sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "caden" },
    [2019] = new[] { "sophia", "liam", "olivia", "jackson", "emma", "noah", "ava", "aiden", "aria", "grayson" },
    [2020] = new[] { "olivia", "noah", "emma", "liam", "ava", "elijah", "isabella", "oliver", "sophia", "lucas" }
};

var random = new Random();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService("dotnet-name"))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddOtlpExporter());

builder.Services.AddHttpClient();

var app = builder.Build();

app.MapGet("/", () => Results.Content("service: <a href='/name'>/name</a>", "text/html"));

app.MapGet("/name", async (HttpContext ctx, IHttpClientFactory clientFactory) =>
{
    Thread.Sleep(random.Next(250));
    var httpClient = clientFactory.CreateClient();
    var year = await GetYear(httpClient);
    if (year == null)
        return Results.Problem("Error getting year from year service");
    var name = GetName(year.Value);
    return Results.Json(new
    {
        language = "dotnet",
        year = year.Value,
        name,
        generated = DateTime.UtcNow
    });
});

async Task<int?> GetYear(HttpClient httpClient)
{
    try
    {
        var data = await httpClient.GetFromJsonAsync<YearResponse>("http://localhost:6001/year");
        return data?.Year;
    }
    catch
    {
        return null;
    }
}

string GetName(int year)
{
    var names = namesByYear[year];
    return names[random.Next(names.Length)];
}

app.Run("http://0.0.0.0:6002");

record YearResponse(string Language, int Year, DateTime Generated);
