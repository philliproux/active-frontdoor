using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace front_door_blue_green_fika_app
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<CookiePolicyOptions>(options =>
            {
                // This lambda determines whether user consent for non-essential cookies is needed for a given request.
                options.CheckConsentNeeded = context => true;
                options.MinimumSameSitePolicy = SameSiteMode.None;
            });


            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_2);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.Use(async (context, next) =>
            {
                context.Response.GetTypedHeaders().CacheControl =
                    new Microsoft.Net.Http.Headers.CacheControlHeaderValue()
                    {
                        NoCache = true,
                        NoStore = true,
                        //Public = true,
                        //MaxAge = TimeSpan.FromSeconds(10)
                    };
                context.Response.Headers["X-XSS-Protection"] = "0";
                context.Response.Headers["Phil-UID"] = new string[] { Guid.NewGuid().ToString() };
                context.Response.Headers[Microsoft.Net.Http.Headers.HeaderNames.Expires] = "-1";
                await next();
            });

            app.UseHttpsRedirection();
            app.UseStaticFiles(new StaticFileOptions()
            {
                //OnPrepareResponse = context =>
                //{
                //    context.Context.Response.Headers.Add("Cache-Control", "no-cache, no-store");
                //    context.Context.Response.Headers.Add("Expires", "-1");
                //}
            });

            //app.UseMvc();
            app.UseMvcWithDefaultRoute();
        }
    }
}
