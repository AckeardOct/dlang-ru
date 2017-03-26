module mailer;

import vibe.mail.smtp;
import std.string;
import std.conv;
import std.file;
import std.stdio;

import configurator : cfg;

class MailTemplates
{
    private string registration;
    
    this()
    {
        registration = readText(cfg().mailTemplates ~ "/registration.email");    
    }
    
    string getRegistrationText(string _name, string _link)
    {
        string ret = registration;
        ret = ret.replace("#{name}", _name).replace("#{link}", _link);        
        return ret;
    }
}

class Mailer
{
    static private Mailer singleton;
    static private MailTemplates mailTemplates;
    static private SMTPClientSettings client;    
	    
    private this() 
    {
        client = new SMTPClientSettings(cfg().mailServer.ip, cfg().mailServer.port);
        mailTemplates = new MailTemplates();
    }   
        
    static Mailer opCall()
    {
        if(!singleton)
            singleton = new Mailer;
        return singleton;
    }
    
    void sendRegisterLink(string _name, string _mail, string _link)
	{
       Mail email = new Mail;
       email.headers["Sender"] = "REG BOT <" ~ cfg().mailAddress ~ ">";
       email.headers["From"] = "<" ~ cfg().mailAddress ~ ">";
	   email.headers["To"] = "<" ~_mail~ ">";
	   email.headers["Subject"] = "Registration Dlang.ru";
	   email.headers["Content-Type"] = "text/html;charset=utf-8";       
	   email.bodyText ~= mailTemplates.getRegistrationText(_name, _link);
       
       sendMail(client, email);       
	}   
}
