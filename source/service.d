module service;

import vibe.d;

import users;
import base;

immutable string MONGO_IP = "127.0.0.1";
immutable string NOT_VALID_LOGIN = "Логин и пароль должен иметь не меньше 
                  3х символов и содержать 'A-z', '0-9', '-', '_'.";

class MainService
{
    private DataBase db;
    private SessionVar!(UserInfo, "settings") userInfo;
    
    this() {
        db = new DataBase("127.0.0.1");
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
    void postRegister(bool _post, string login, string name, string pwd, string pwd2)
    {
        enforce(login.isValidLoginAndPwd(), NOT_VALID_LOGIN);
                
        enforce(!db.hasUser(login), "Логин " ~login~ " занят.");
        enforce(name.isValidLoginAndPwd(), NOT_VALID_LOGIN);
        enforce(pwd.isValidLoginAndPwd(), NOT_VALID_LOGIN);
        enforce(pwd == pwd2, "Пароли не совпапдают.");
                
        Bson userBson = db.createUser(login, name, pwd);
        userInfo = UserInfo(userBson);
        redirect("./");
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
