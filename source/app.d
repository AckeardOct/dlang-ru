import vibe.vibe;
import service;

immutable string IP = "127.0.0.1:8080";

void main()
{
    string ip = IP.split(":")[0];
    ushort port  = to!ushort(IP.split(":")[1]);    
        
    auto router = new URLRouter;
    router.registerWebInterface(new MainService);    
    router.get("*", serveStaticFiles("public/"));
    
    auto settings = new HTTPServerSettings;
	settings.port = port;
	settings.bindAddresses = ["::1", ip];
    settings.sessionStore = new MemorySessionStore;
	listenHTTP(settings, router);

	logInfo("Please open http://%s:%d/ in your browser.", ip, port);
	runApplication();
}

