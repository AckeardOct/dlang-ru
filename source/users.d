module users;

import  vibe.data.bson;

enum eRights {
      guest = 0
    , user  = 1
    , admin = 2        
}

pure eRights toRights(immutable string _rights) 
{
    switch(_rights) {        
        case  "user" : return eRights.user;
        case "admin" : return eRights.admin;
        case "guest" : default:        
            return eRights.guest;
    }        
}

struct UserInfo
{
    BsonObjectID id;
    string name = "Guest";
    string login = "guest";
    eRights rights = eRights.guest;
    
    this(ref Bson _bson) {
        this.id     = _bson["_id"].get!BsonObjectID;
        this.name   = _bson["name"].get!string;
        this.login  = _bson["login"].get!string;
        this.rights = _bson["rights"].get!string.toRights();
    }
    
    pure bool logined() { return rights != eRights.guest; }
    pure bool admin() { return rights == eRights.admin; }
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
