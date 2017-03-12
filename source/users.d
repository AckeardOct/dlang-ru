module users;

import vibe.data.bson;
import std.stdio;
import std.string;
import std.algorithm.searching : canFind;
import std.digest.md;
import mailer;

enum eRights { guest, user, admin }

pure eRights toRights(immutable string _rights) 
{
    switch(_rights) {
        case  "user" : return eRights.user;
        case "admin" : return eRights.admin;
        case "guest" : default:
            return eRights.guest;
    }
}

unittest {
    assert("guest".toRights() == eRights.guest);
    assert("user".toRights() == eRights.user);
    assert("admin".toRights() == eRights.admin);
    
    assert("guest".toRights() != eRights.user);
    assert("user".toRights() != eRights.admin);
    assert("admin".toRights() != eRights.guest);
}

struct UserInfo
{
    BsonObjectID id;
    bool auth = false;
    string name = "Guest";
    string login = "guest";
    string mail;
    eRights rights = eRights.guest;
    
    this(Bson _bson) {
        this.id     = _bson["_id"].get!BsonObjectID;
        this.auth   = _bson["auth"].get!bool;
        this.name   = _bson["name"].get!string;
        this.login  = _bson["login"].get!string;
        this.mail   = _bson["mail"].get!string;
        this.rights = _bson["rights"].get!string.toRights();
    }
    
    pure bool logined() { if(!auth) return false; return rights != eRights.guest; }
    pure bool admin()   { if(!auth) return false; return rights == eRights.admin; }
    
    private string createRegisterCode()
    {
        string code;
        if(!id.valid || login.empty || login == "guest")
            return code;
                
        code ~= id.toString;
        code ~= "/";
        code ~= toHexString(md5Of(login.toLower())).toLower();
        
        return code;
    }
    
    void sendRegisterLink()
    {
        string link = "http://127.0.0.1:8080/confirm/";
        link ~= createRegisterCode();                
        Mailer.get().sendRegisterLink(name, mail, link);
    }       
}

pure bool isValidLoginAndPwd(const ref string _str) 
{
    if(_str.length < 3)
        return false;
	foreach(ch; _str) {
		switch(ch) {
			case 'A': .. case 'Z':				
			case 'a': .. case 'z':				
			case '0': .. case '9':				
			case '-': case '_':							
				continue;
			default:
				return false;
		}
	}
	return true;
}

unittest {
    string str = "User";
    assert(str.isValidLoginAndPwd() == true);
    str = "lo";
    assert(str.isValidLoginAndPwd() != true);
}

pure bool isValidMail(const ref string _str) 
{    
    if(_str.length < 3)
        return false;
    if(!_str.canFind("@") || !_str.canFind('.'))
        return false;
	foreach(ch; _str) {
		switch(ch) {
			case 'A': .. case 'Z':				
			case 'a': .. case 'z':				
			case '0': .. case '9':				
			case '-': case '_': case '!': case '@': case '#':
            case '$': case '%': case '^': case '&': case '*':
            case '(': case ')': case '+': case '=': case ';':
            case '?': case '.':						
				continue;
			default:
				return false;
		}
	}
	return true;
}

unittest {
    string str = "morhor@mail.ru";
    assert(str.isValidMail() == true);
    str = "Lalka!1";
    assert(str.isValidMail() != true);
}
