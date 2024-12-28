ASP.NET MVC'de Action Filter'lar, bir controller action'ı çalıştırılmadan önce 
veya sonra özel bir mantık çalıştırmak için kullanılan öznitelikler (attributes) veya sınıflardır. 
Uygulama çapında, controller seviyesinde veya action seviyesinde çalışabilirler ve genellikle aşağıdaki durumlarda kullanılırlar:

1. Ön İşlemler (Before Execution)
Bir action method çağrılmadan önce belirli bir kodun çalıştırılmasını sağlar. Örneğin:

Kullanıcının yetkilendirilmesi veya kimlik doğrulaması
Giriş parametrelerinin doğrulanması
Günlük kaydı (logging)
2. Son İşlemler (After Execution)
Action method çalıştıktan sonra belirli bir kodun çalıştırılmasını sağlar. Örneğin:

Günlük kaydı (action'ın sonucunu kaydetmek)
Response'a ek bilgi eklemek (örn: özel başlıklar eklemek)
Kaynakların serbest bırakılması
3. Hata Yönetimi (Exception Handling)
Bir action içinde oluşabilecek hataları yakalayıp özel bir işlem yapmak için kullanılabilir.

4. Sonuç İşlemleri (Result Execution)
Action method'un sonucunun işlenmesini özelleştirmek için kullanılır. Örneğin:

View sonucu üzerinde değişiklik yapmak
Response'u cache'lemek
Kullanılan Temel Metotlar
Bir Action Filter genellikle şu dört temel metodu kullanır:

OnActionExecuting
Action method çağrılmadan önce çalışır.
OnActionExecuted
Action method çalıştıktan sonra çalışır.
OnResultExecuting
Action'ın ürettiği sonuç (örneğin bir View) döndürülmeden önce çalışır.
OnResultExecuted
Action'ın sonucu döndürüldükten sonra çalışır.
------------------------------------------------------------

Uygulama Alanları
Kimlik Doğrulama ve Yetkilendirme: Kullanıcı yetkilerini kontrol etmek için.
Loglama: Hangi action çağrılmış, kim çağırmış gibi bilgileri loglamak.
Hata Yönetimi: Hataları yakalayıp özelleştirilmiş hata sayfaları göstermek.
Performans Ölçümü: Action'ın çalışma süresini ölçmek.
Response Manipülasyonu: Action sonuçlarını özelleştirmek veya cache işlemleri yapmak.
Action Filter'lar, tekrarlayan işleri merkezi bir yerde çözmek ve Clean Code ilkelerine uymak için oldukça kullanışlıdır.

------------------------------------------------------------

Homecontrollerda bir tane post ındex açtım
bu posta Model ıcınde home klasorunde bır IndexVıewmodel yazdım
------------------------------------------------------------
homecotnroller ıcını guncelleıdm 
[HttpPost]
    public IActionResult Index(IndexViewModel model){
        return View();
    }
------------------------------------------------------------
ActionFilter klasoru acıp ıcınde ındexActıonFilter actım 
public class IndexActionFilter : IActionFilter
interfaceını ımplement ettım 
------------------------------------------------------------
HomeController a posttan sonra bunu ekledım .
 [ServiceFilter(typeof(IndexActionFilter))]
------------------------------------------------------------
Viewına gittim
form actım bıtane 
    <form method="post" action="/Home/Index">
        <input type="text" name="Email">
        <input type="text" name="Name">
        <input type="submit" value="Gönder">
    </form>
------------------------------------------------------------
programcs e gidip 
    builder.Services.AddScoped<IndexActionFilter>();
ekledım
------------------------------------------------------------
ındex actıonfıltera regex modulu yazdık 

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

------------------------------------------------------------

FilterExceptionMessage i aldım homecontroller ıcındekı ındexactıonfilter verdıgım yerde 

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

        return View();
    }

ekledim.

------------------------------------------------------------
IndexVıewModele

    public bool IsCorrect { get; set;}
    public string ActionFilterErrorMessage { get; set;}

ekledim.
------------------------------------------------------------

View Home Indexe

    @model IndexViewModel

    @if (Model != null)
    {
        @if (!Model.IsCorrect)
        {
            <p>@Model.ActionFilterErrorMessage</p>

        }
    }

------------------------------------------------------------
Home controller duzenlendı 

     public IActionResult Index()
    {
        IndexViewModel model = new IndexViewModel();
        model.IsCorrect = false;
        return View(model);
    }

------------------------------------------------------------
