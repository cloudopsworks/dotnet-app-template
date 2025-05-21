using Microsoft.AspNetCore.Mvc.Testing;
using NUnit.Framework;
using System.Net;
using System.Text.Json;

namespace HelloWorldApi.Tests.Integration;

[TestFixture]
public class HealthCheckIntegrationTests
{
    private WebApplicationFactory<HelloWorldApi> _factory;
    private HttpClient _client;

    [OneTimeSetUp]
    public void Setup()
    {
        _factory = new WebApplicationFactory<HelloWorldApi>();
        _client = _factory.CreateClient();
    }

    [Test]
    public async Task Health_Endpoint_Returns_Healthy()
    {
        // Act
        var response = await _client.GetAsync("/health");
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<HealthResponse>(content, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        // Assert
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        Assert.That(result, Is.Not.Null);
        Assert.That(result.Status, Is.EqualTo("healthy"));
    }

    [Test]
    public async Task HealthLive_Endpoint_Returns_Healthy()
    {
        // Act
        var response = await _client.GetAsync("/health/live");

        // Assert
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [OneTimeTearDown]
    public void TearDown()
    {
        _client.Dispose();
        _factory.Dispose();
    }
}