#include <iostream>
#include <string>
#include <pqxx/pqxx>
#include <future>
#include "PGClient.h"
#include "HTTPServer.h"

int main()
{
    try
    {
        HTTPServer* srv = new HTTPServer("192.168.0.1", "5431", new PGClient("yachtsapp", "pwd"));

        std::thread th_srv(&HTTPServer::Start, srv, true);

        std::this_thread::sleep_for(std::chrono::minutes (20));

        srv->Stop();
        th_srv.join();
    }
    catch (std::exception const &e)
    {
        std::cerr << e.what() << '\n';
        return 1;
    }
    return 0;
}
