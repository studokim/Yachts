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
        //pqxx::connection C("host=localhost port=5432 user=yachtsapp password=pwd dbname=yachts connect_timeout=10");
        //pqxx::connection C("postgresql://yachtsapp:pwd@localhost:5432/yachts?connect_timeout=10");

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
