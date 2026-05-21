using ChaloJi.Modules.Auth.Data;
using ChaloJi.Modules.Auth.Services.Class;
using ChaloJi.Modules.Auth.Services.Interface;
using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore; 

namespace ChaloJiBackend
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Services.AddControllers()
                .AddApplicationPart(typeof(ChaloJi.Modules.Auth.Controllers.AuthController).Assembly);

            builder.Services.AddAuthorization();

            builder.Services.AddOpenApi();

            builder.Services.AddDbContext<AuthDbContext>(options =>
            {
                options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"));
            });

            builder.Services.AddScoped<IAuthService, AuthService>();

            var app = builder.Build();

            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
                app.MapScalarApiReference();
            }

            app.UseHttpsRedirection();
            app.MapControllers();

            app.UseAuthorization();
            app.Run();
        }
    }
}