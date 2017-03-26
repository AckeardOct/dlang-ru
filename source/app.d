import vibe.vibe;
import service;
import std.stdio;
import configurator : cfg;

void main()
{
    writeln("=============== CONFIG ===============");
    writeln(cfg());
    writeln("======================================");
        
    
    auto router = new URLRouter;
    router.registerWebInterface(new MainService);    
    router.get("*", serveStaticFiles("public/"));
        
    
    auto settings = new HTTPServerSettings;
	settings.port = cfg().webServer.port;
	settings.bindAddresses = ["::1", cfg().webServer.ip];
    settings.sessionStore = new MemorySessionStore;
    
    if(cfg().useHttps) {
        settings.tlsContext = createTLSContext(TLSContextKind.server);
        settings.tlsContext.useCertificateChainFile("ssl/server.crt");
        settings.tlsContext.usePrivateKeyFile("ssl/server.key");
    }
    
	listenHTTP(settings, router);

	logInfo("Please open http://%s:%d/ in your browser.", cfg().webServer.ip, cfg().webServer.port);
	runApplication();
}

