#include "httplib.h"
using namespace httplib;

#ifndef YACHTS_server_H
#define YACHTS_server_H


class HTTPServer {
public:
    HTTPServer() = delete;

    explicit HTTPServer(const std::string& host, const std::string& port, PGClient* db)
    : host(host.c_str()), port(std::stoi(port)), db(db) {}

    void Start(bool force = false)
    {
        std::cout << "Server at " << host << ":" << port << " started." << std::endl;
        db->Connect(true);
        if (force || server == nullptr) {
            server = new Server();

            RegisterWelcomeHandler();
            RegisterGetCollectionHandlers();
            // We can go without insertionHandlers and HttpPost
            // if there are appropriate functions in the database.
            RegisterFunctionsHandlers();

            server->listen(host, port);
        }
    }

    void RegisterWelcomeHandler()
    {
        server->Get("/", [](const Request &req, Response &res) {
            res.set_content("<h>Welcome to Bluebird!</h>", "text/html");
        });
    }

    void RegisterGetCollectionHandlers()
    {
        server->Get("/classes", [this](const Request &req, Response &res) {
            auto result = db->SelectAll("vclass");
            res.set_content(result, "application/json");
        });

        server->Get("/clients", [this](const Request &req, Response &res) {
            auto result = db->SelectAll("vclient");
            res.set_content(result, "application/json");
        });

        server->Get("/inspections", [this](const Request &req, Response &res) {
            auto result = db->SelectAll("vinspection", 2, true);
            res.set_content(result, "application/json");
        });

        server->Get("/invoices", [this](const Request &req, Response &res) {
            auto result = db->SelectAll("vinvoice", 6, true);
            res.set_content(result, "application/json");
        });

        server->Get("/rents", [this](const Request &req, Response &res) {
            auto result = db->SelectAll("vrent", 5, true);
            res.set_content(result, "application/json");
        });

        server->Get("/yachts", [this](const Request &req, Response &res) {
            auto result = db->Select("select vyacht.*, vclass.dailycost, vinspection.date as inspected,"
                                     "vinspection.statusok as ok, checktakenRent(vyacht.yachtid) as taken\n"
                                     " from vyacht join vclass on vclass.classid = vyacht.classid\n"
                                     " join vinspection on vinspection.yachtid = vyacht.yachtid\n"
                                     " where vinspection.date = (select max(date) from vinspection\n"
                                     " where vinspection.yachtid = vyacht.yachtid)");
            res.set_content(result, "application/json");
        });
    }

    void RegisterFunctionsHandlers()
    {
        server->Get("/discount", [this](const Request &req, Response &res) {
            auto docId = req.get_param_value("documentid");
            auto query = std::string("select calculatediscountfunction(\'").append(docId).append("\') as Discount");
            auto result = db->CallFunction(query);
            res.set_content(result, "application/json");
        });

        server->Get("/revenue", [this](const Request &req, Response &res) {
            auto docId = req.get_param_value("documentid");
            auto query = std::string("select calculaterevenuefunction(\'").append(docId).append("\') as Revenue");
            auto result = db->CallFunction(query);
            res.set_content(result, "application/json");
        });

        server->Patch("/prices", [this](const Request &req, Response &res) {
            auto percent = req.get_param_value("percent");
            auto query = std::string("select updatepricesfunction(").append(percent).append(") as Result");
            auto result = db->CallFunction(query);
            res.set_content(result, "text/plain");
        });

        server->Patch("/pay", [this](const Request &req, Response &res) {
            auto docId = req.get_param_value("documentid");
            auto amount = req.get_param_value("amount");
            auto method = req.get_param_value("method");
            auto query = std::string("select payinvoicesfunction(\'")
                    .append(docId).append("\', ")
                    .append(amount).append(", \'")
                    .append(method).append("\') as Result");
            auto result = db->CallFunction(query);
            res.set_header("result", "ok");
            res.set_content(result, "text/plain");
        });
    }

    void Stop()
    {
        db->Disconnect();
        if (server != nullptr && server->is_running()) {
            server->stop();
            delete server;
            server = nullptr;
        }
        std::cout << "Server at " << host << ":" << port << " stopped." << std::endl;
    }

    ~HTTPServer()
    {
        Stop();
        delete db;
        db = nullptr;
        delete host;
        host = nullptr;
    }

private:
    char const* host;
    int port;
    Server* server;
    PGClient* db;
};


#endif //YACHTS_server_H