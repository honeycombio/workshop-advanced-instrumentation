var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var years = new[] { 2015, 2016, 2017, 2018, 2019, 2020 };
var random = new Random();

app.MapGet("/", () => Results.Content("service: <a href='/year'>/year</a>", "text/html"));

app.MapGet("/year", () =>
{
    Thread.Sleep(random.Next(250));
    var year = GetYear();
    return Results.Json(new
    {
        language = "dotnet",
        year,
        generated = DateTime.UtcNow
    });
});

int GetYear()
{
    var rnd = random.Next(years.Length);
    var year = years[rnd];
    Thread.Sleep(random.Next(250));
    return year;
}

app.Run("http://0.0.0.0:6001");
