using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

public class IndexActionFilter : IActionFilter
{
    public void OnActionExecuted(ActionExecutedContext context)
    {
        // bu metot, action çağırıldıktan sonra çalışır!!

    }

    public void OnActionExecuting(ActionExecutingContext context)
    {
         // Model olarak gelen email alanının uygn email olup olmadığını konrol edelim

        // bu kontrolü regex denen bir teknmoloji ile yapacağız.


        

        var modelResult = context.ActionArguments.Values.FirstOrDefault();
        if (modelResult == null)
        {
            // ActionResult actiondan önce çalışacağı için, geriye result dönemiz gerekmektedir!!

            // context.result a eğer validasyondan geriye olumsuz bir dönüş varsa, backrequestobjectrewulst verilebilir
            context.Result = new BadRequestObjectResult("Model yok");
        }
        
        var indexViewModel = (IndexViewModel)context.ActionArguments["model"];

        if (indexViewModel != null)
        {

            if (indexViewModel.Email != null)
            {
                //email'in formatının doğru olduğunu Regex teknolojisi ile kontrol edelim!!
                var regex = new Regex("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$");
                bool isOk = regex.IsMatch(indexViewModel.Email);
                if (!isOk)
                {
                    // aşağıdaki gibi bir sonuç döndüğümüzde, ekran viewdan bağımsız bir şekilde oluşmaktadır!!

                    // eğer akışı bozmayıp, index post actiona mesaj gödnermek isterseniz : 

                    context.HttpContext.Items["FilterExceptionMessage"]="Email uygun değildir";


                    // aşağıdaki kod, controllara hiç uğramadan bir ekran açıp bizim mesajı orada yayınlar
                    //context.Result = new BadRequestObjectResult("Email uygun değil");
                    //return;
                }
            }
        }
    }
}