module base;

import std.stdio;
import vibe.d;
import core.stdc.stdlib : exit;

import configurator;

alias DataBase db;

class DataBase
{
    static private DataBase singleton;
    private MongoClient db;
    private MongoCollection usersColl;
    
    private this()
    {
        try {
            db = connectMongoDB(cfg().mongoServer);
            usersColl  = db.getCollection("server.users");
            
            // Default admin user
            if(this.getUser("admin").isNull){
                Bson newUser = Bson.emptyObject;
                newUser["login"]  = "admin";
                newUser["name"]   = "admin";
                newUser["rights"] = "admin";
                newUser["auth"]   = true;
                newUser["birth"]  = BsonDate(Clock.currTime);
                newUser["mail"]   = "admin@admin.ru";
                newUser["pwd"]    = toHexString(md5Of("admin")).toLower();
                usersColl.insert(newUser); 
            }
            
        } catch {
            writeln("[ERROR] Can't connect to MongoDb by ip: ", cfg().mongoServer);
            exit(1);
        }
    }
    
    static DataBase opCall()
    {
        if(!singleton)
            singleton = new DataBase;
         return singleton;
    }
    
    Bson getUser(immutable string _login)
    {
        Bson req = Bson.emptyObject;
        req["login"] = _login.toLower();
        return usersColl.findOne(req);
    }
    
    Bson getUser(BsonObjectID _id)
    {
        Bson req = Bson.emptyObject;
        req["_id"] = _id;
        return usersColl.findOne(req);
    }
    
    bool hasUser(immutable string _login)
    {
        return !getUser(_login).isNull;
    }
    
    Bson createUser(immutable string _login, immutable string _name, immutable string _mail, immutable string _pwd)
    {
        Bson newUser = Bson.emptyObject;
        newUser["login"]  = _login.toLower();
        newUser["name"]   = _name;
        newUser["rights"] = "user";
        newUser["auth"]   = false;
        newUser["birth"]  = BsonDate(Clock.currTime);
        newUser["mail"]   = _mail;
        newUser["pwd"]    = toHexString(md5Of(_pwd)).toLower();
        usersColl.insert(newUser);        
        
        return getUser(_login);
    }
    
    Bson authUser(ref Bson _user)
    {                                        
        _user["auth"] = true;
        Bson req = Bson.emptyObject;
        req["_id"] = _user["_id"].get!BsonObjectID;                
        
        usersColl.update(req, _user);
        return usersColl.findOne(req);
    }
}
