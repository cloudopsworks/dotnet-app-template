
using Microsoft.AspNetCore.Mvc;
using NUnit.Framework;

namespace HelloWorldApi.Tests.Controllers;

[TestFixture]
public class HealthControllerTests
{
    private HealthController _controller;

    [SetUp]
    public void Setup()
    {
        _controller = new HealthController();
    }

    [Test]
    public void Get_ReturnsOkResult()
    {
        // Act
        var result = _controller.Get();

        // Assert
        Assert.That(result, Is.InstanceOf<OkObjectResult>());
    }

    [Test]
    public void Get_ReturnsCorrectResponse()
    {
        // Act
        var result = _controller.Get() as OkObjectResult;

        // Assert
        Assert.That(result, Is.Not.Null);
        var value = result!.Value as dynamic;
        Assert.That(value.status.ToString(), Is.EqualTo("healthy"));
    }
}