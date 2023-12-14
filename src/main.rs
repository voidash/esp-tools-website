#[macro_use]
extern crate lazy_static;

extern crate tera;

use tera::{Tera,Context};


lazy_static!{
    pub static ref TEMPLATES: Tera = {
        let mut tera = match Tera::new("./templates/**/*") {
            Ok(t) => t,
            Err(e) => {
                println!("Parsing error(s): {}", e);
                ::std::process::exit(1);
            }
        };
        tera.autoescape_on(vec![".html", ".sql"]);
        tera
    };
}

use actix_web::{get, App,HttpResponse, HttpServer, Responder};
use actix_files as fs;

#[get("/")]
async fn hello() -> impl Responder {
    let context = Context::new();

    let response = TEMPLATES.render("countdown.html",&context).unwrap();
    HttpResponse::Ok().body(response)
}



#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(fs::Files::new("/static","./static/").show_files_listing())
            .service(hello)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
