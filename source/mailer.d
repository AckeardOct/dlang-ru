module mailer;

import vibe.mail.smtp;
import std.string;
import std.conv;
import std.file;
import std.stdio;

immutable string ADDRESS = "no-reply@dlang.com";

interface IMailer
{    
    void sendRegisterLink(string _name, string _mail, string _link);
    static bool create(string _host, ushort _port);
    static IMailer get();
}

class MailTemplates
{
    private string dirPath;
    private string registration;
    
    this(string _dirPath)
    {
        dirPath = _dirPath;
        registration = readText(this.dirPath ~ "/registration.email");    
    }
    
    string getRegistrationText(string _name, string _link)
    {
        string ret = registration;
        ret = ret.replace("#{name}", _name).replace("#{link}", _link);        
        return ret;
    }
}

unittest {
    MailTemplates tmp = new MailTemplates("db/mail-templates/");
    writeln(tmp.getRegistrationText("NAME", "LINK"));
}

class Mailer : IMailer
{
    static private Mailer pointer = null;
    static private MailTemplates mailTemplates = null;
    static private SMTPClientSettings client;    
	    
    private this() { }
    
    static bool create(string _host, ushort _port, string _mailDir) {
        if(!pointer) {
            client = new SMTPClientSettings(_host, _port);
            pointer = new Mailer;
            mailTemplates = new MailTemplates(_mailDir);
            return true;
        }
        else {
            return false;
        }
    }   
        
    static IMailer get() 
    {
        assert(pointer);
        return pointer;
    }
    
    void sendRegisterLink(string _name, string _mail, string _link)
	{
       Mail email = new Mail;
       email.headers["Sender"] = "REG BOT <" ~ADDRESS~ ">";
       email.headers["From"] = "<" ~ADDRESS~ ">";
	   email.headers["To"] = "<" ~_mail~ ">";
	   email.headers["Subject"] = "Registration Dlang.ru";
	   email.headers["Content-Type"] = "text/html;charset=utf-8";       
	   email.bodyText ~= mailTemplates.getRegistrationText(_name, _link);
       
       sendMail(client, email);       
	}   
}
