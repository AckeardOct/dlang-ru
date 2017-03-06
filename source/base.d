module base;

import std.stdio;
import vibe.d;
import core.stdc.stdlib : exit;

class DataBase
{
    private MongoClient db;
    private MongoCollection usersColl;
    
    this(immutable string _ip)
    {
        try {
            db = connectMongoDB(_ip);
            usersColl  = db.getCollection("server.users");
            
        } catch {
            writeln("[ERROR] Can't connect to MongoDb by ip: ", _ip);
            exit(1);
        } 
    }
    
    Bson getUser(immutable string _login)
    {
        Bson req = Bson.emptyObject;
        req["login"] = _login.toLower();
        return usersColl.findOne(req);
    }     
    
    bool hasUser(immutable string _login)
    {
        return !getUser(_login).isNull;
    }
    
    Bson createUser(immutable string _login, immutable string _name, immutable string _pwd)
    {
        Bson newUser = Bson.emptyObject;
        newUser["login"] = _login.toLower();
        newUser["name"]  = _name;
        newUser["rights"] = "user";
        newUser["pwd"] = toHexString(md5Of(_pwd)).toLower();
        usersColl.insert(newUser);
        
        return getUser(_login);  
    }
}
