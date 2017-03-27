module configurator;

import std.stdio;
import std.conv;
import std.string;
import std.file;
import std.json;

immutable string file = "cfg.json";

alias Configurator cfg;

class Ip
{
    string ip;
    ushort port;
    
    this(string _str)
    {
        ip = _str.split(":")[0];
        port = to!ushort(_str.split(":")[$ - 1]);
    }
    
    override pure string toString()
    {
        string ret = ip ~ ":";
        ret ~= to!string(port);
        return ret;
    }
}

class Configurator
{
    static private Configurator singleton;
    
    Ip webServer;
    string mongoServer;
    Ip mailServer;
    string mailAddress;
    string mailTemplates;
    bool useHttps;
    
    private this()
    {
        JSONValue tmp = true;
        JSONValue j = parseJSON(readText(file));
        webServer = new Ip(j["webServer"].str);
        mongoServer = j["mongoServer"].str;
        mailServer = new Ip(j["mailServer"].str);
        mailAddress = j["mailAddress"].str;
        mailTemplates = j["mailTemplates"].str;
        useHttps = (j["useHttps"].type() == JSON_TYPE.TRUE ? true : false);
        //writeln("Bool: ", useHttps == true);
    }
    
    static Configurator opCall()
    {
        if(!singleton)
            singleton = new Configurator;
        return singleton;
    }
    
    override pure string toString()
    {
        string ret;
        ret ~= "webServer: " ~ webServer.toString() ~ "\n";
        ret ~= "mongoServer: " ~ mongoServer ~ "\n";
        ret ~= "mailServer: " ~ mailServer.toString() ~ "\n";
        ret ~= "mailAddress: " ~ mailAddress ~ "\n";
        ret ~= "mailTemplates: " ~ mailTemplates ~ "\n";
        ret ~= "useHttps: " ~ (useHttps ? "true" : "false") ~ "\n";
        return ret;
    }
}
