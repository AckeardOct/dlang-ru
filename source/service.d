module service;

import vibe.d;
import std.stdio;

import users;
import base;
import mailer;

immutable string MAIL_DIR = "db/mail-templates/";
immutable string MONGO_IP = "127.0.0.1";
immutable string MAIL_SERVER = "localhost:25";

immutable string NOT_VALID_LOGIN = "Логин и пароль должен иметь не меньше 
                  3х символов и содержать 'A-z', '0-9', '-', '_'.";
immutable string NOT_VALID_MAIL = "Почта должна иметь не меньше 
                  3х символов и содержать 'A-z', '0-9', '-', '_'......";                  

class MainService
{
    private DataBase db;
    private SessionVar!(UserInfo, "settings") userInfo;
    
    this() {
        db = new DataBase(MONGO_IP);
        
        string host = MAIL_SERVER.split(":")[0];
        ushort port  = to!ushort(MAIL_SERVER.split(":")[1]);    
        
        Mailer.create(host, port, MAIL_DIR);
    }    
    
    @path("/")
    void getHome()
    {
        UserInfo ui = userInfo;
        render!("home.dt", ui);
    }
    
    @path("/login")
    void getLogin(string _error = null)
    {
        UserInfo ui = userInfo;
        render!("login.dt", ui, _error);
    }
    
    @post @errorDisplay!getLogin
    void postLogin(bool _post, string login, string password) 
    {
        enforce(login.isValidLoginAndPwd(), NOT_VALID_LOGIN);
        
        Bson userBson = db.getUser(login);
        enforce(!userBson.isNull, "Логин " ~login~ " неверен.");
        enforce(userBson["auth"].get!bool, "Логин " ~login~ " не подтверждён.");
        enforce(userBson["pwd"].get!string.toLower() == toHexString(md5Of(password)).toLower(),
            "Неверный пароль.");

        userInfo = UserInfo(userBson);
        redirect("./");
    }
    
    @onlyLogined @path("/logout")
    void getLogout(bool _onlyLogined, scope HTTPServerResponse res)
    {
        userInfo = UserInfo.init;
        res.terminateSession();
        redirect("/");
    }       
    
    @onlyLogined @path("/user")
    void getUser(bool _onlyLogined) 
    {
        UserInfo ui = userInfo;
        render!("user.dt", ui);
    } 
            
    @path("/register")
    void getRegister(string _error = null)
    {
        UserInfo ui = userInfo;
        render!("register.dt", ui, _error);
    }  
        
    @post @errorDisplay!getRegister @path("/register")
    void postRegister(bool _post, string login, string name, string mail, string pwd, string pwd2)
    {
        enforce(login.isValidLoginAndPwd(), NOT_VALID_LOGIN);
        enforce(mail.isValidMail(), NOT_VALID_MAIL);
                
        enforce(!db.hasUser(login), "Логин " ~login~ " занят.");
        enforce(name.isValidLoginAndPwd(), NOT_VALID_LOGIN);
        enforce(pwd.isValidLoginAndPwd(), NOT_VALID_LOGIN);
        enforce(pwd == pwd2, "Пароли не совпапдают.");

        Bson userBson = db.createUser(login, name, mail, pwd);
        UserInfo ui = UserInfo(userBson);
        ui.sendRegisterLink();
        redirect("/");
    }
    
    @path("/confirm/:id/:loginHash")
    void getConfirm(HTTPServerRequest _req)
    {
        Bson userBson = db.getUser(BsonObjectID.fromString(_req.params.get("id")));
        string login = userBson["login"].get!string;
        if(toHexString(md5Of(login.toLower())).toLower() != _req.params.get("loginHash")){                                
            redirect("/");        
        }
        
        UserInfo user = UserInfo(db.authUser(userBson));
        if(user.logined)
            userInfo = user;
        redirect("/");        
    } 
    
    // Mixin Magic
    private enum onlyLogined = before!checkLogined("_onlyLogined");  
    private bool checkLogined(scope HTTPServerRequest req, scope HTTPServerResponse res)     
    {                
        if(userInfo.rights == eRights.guest) 
            redirect("/login");
        return true;
    }
         
    private enum onlyAdmin = before!checkAdmin("_onlyAdmin");
    private bool checkAdmin(scope HTTPServerRequest req, scope HTTPServerResponse res)     
    {        
        if(userInfo.rights != eRights.admin) 
            redirect("/");
        return true;
    }           
    
    private enum post = before!checkPost("_post");
    private bool checkPost(scope HTTPServerRequest req, scope HTTPServerResponse res)     
    {           
        if(req.method != HTTPMethod.POST)
            redirect("/");
        return true;
    }
    
    mixin PrivateAccessProxy;
}
