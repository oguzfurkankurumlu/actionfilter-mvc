using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using actionfilter_mvc.Models;

namespace actionfilter_mvc.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

     public IActionResult Index()
    {
        IndexViewModel model = new IndexViewModel();
        model.IsCorrect = false;
        return View(model);
    }

[HttpPost]
 [ServiceFilter(typeof(IndexActionFilter))]
    public IActionResult Index(IndexViewModel model){

           // Action filterden gelen mesajı burada yakalayabiliriz
        if (HttpContext.Items["FilterExceptionMessage"] != null)
        {
            var actionFilterMessage = HttpContext.Items["FilterExceptionMessage"].ToString();
            model.ActionFilterErrorMessage = actionFilterMessage;
            model.IsCorrect = false;
        }

        return View(model);
    }
    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
