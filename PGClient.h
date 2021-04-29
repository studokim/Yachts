#include <boost/algorithm/string.hpp>
#include <iostream>

#ifndef YACHTS_PGCLIENT_H
#define YACHTS_PGCLIENT_H


class PGErrorHandler : public pqxx::errorhandler
{
public:
    PGErrorHandler() = delete;

    explicit PGErrorHandler(pqxx::connection& c) :
            pqxx::errorhandler(c), message() {}

    bool operator()(char const msg[]) noexcept override
    {
        message = std::string{msg};
        return true;
    }

    std::string const& Message()
    {
        return message;
    }

    void Reset()
    {
        message.clear();
    }

private:
    std::string message;
};

class PGClient {
public:
    PGClient() = delete;

    explicit PGClient(const std::string& user, const std::string& password,
                      const std::string& host = "localhost", const std::string& port = "5432")
       : conn_string("host=" + host + " port=" + port
                     + " user=" + user + " password=" + password
                     + " dbname=yachts connect_timeout=10") {}

    explicit PGClient(std::string conn_string)
        : conn_string(std::move(conn_string)) {}

    void Connect(bool force = false)
    {
        if (force || conn == nullptr) {
            conn = new pqxx::connection(conn_string);
            handler = new PGErrorHandler(*conn);
        }
        std::cout << "Connected to " << conn->dbname() << '.' << std::endl;
    }

    std::string Select(const std::string& query)
    {
        if (!IsCorrect(query, "select"))
            return "ERROR: Wrong query!";
        pqxx::nontransaction work{*conn};
        pqxx::result result{work.exec(JsonizeQuery(query))};
        return result[0][0].c_str();
    }

    std::string SelectAll(const std::string& tableName, int orderByColumn = 0, bool desc = false)
    {
        std::string query = std::string("SELECT * FROM ").append(tableName);
        if (orderByColumn <= 0)
            return Select(query);
        if (!desc)
            return Select(query.append(" ORDER BY ").append(std::to_string(orderByColumn)));
        return Select(query.append(" ORDER BY ").append(std::to_string(orderByColumn)).append(" DESC"));
    }

    /*std::string Insert(const std::string& query)
    {
        if (!IsCorrect(query, "insert"))
            throw std::runtime_error("ERROR: Wrong query!");
        pqxx::work work{*conn};
        pqxx::result result{work.exec(query)};
        work.commit();
        return result[0][0].c_str();
    }*/

    std::string CallFunction(const std::string& query)
    {
        if (!IsCorrect(query, "select"))
            return "ERROR: Wrong query!";
        try {
            pqxx::work work{*conn};
            pqxx::result result{work.exec(JsonizeQuery(query))};
            work.commit();
            std::string res = result[0][0].c_str();
            std::string notice = Strip(handler->Message());
            handler->Reset();
            if (!notice.empty())
                return JsonizeResult("Result", notice);
            if (!IsEmpty(res))
                return res;
            return JsonizeResult("Result", "ok");
        }
        catch(std::exception& e) {
            std::string error = Strip(e.what());
            return JsonizeResult("Error", error);
        }
    }

    void Disconnect()
    {
        std::cout << "Disconnected from " << conn->dbname() << '.' << std::endl;
        if (conn != nullptr && conn->is_open()) {
            conn->disconnect();
            delete conn;
            conn = nullptr;
        }
    }

    ~PGClient()
    {
        Disconnect();
    }

private:
    std::string const conn_string;
    pqxx::connection* conn;
    PGErrorHandler* handler;

    static std::string JsonizeQuery(const std::string& query)
    {
        // now it looks like
        // select json_agg(t) from (select * from vclass) as t
        return std::string("select json_agg(t) from (").append(query).append(") as t");
    }

    static std::string Strip(const std::string& message)
    {
        // leaves only the first line
        return boost::algorithm::replace_all_copy(message.substr(0, message.find('\n')), "\"", "`");
    }

    static std::string JsonizeResult(const std::string& keyword, const std::string& result)
    {
        // now it looks like
        // [{"keyword" : "result"}]
        return std::string("[{\"").append(keyword).append("\":\"").append(result).append("\"}]");
    }

    static bool IsCorrect(const std::string& query, const std::string& keyword)
    {
        return (query.find(';') == -1) && (boost::algorithm::to_lower_copy(query).find(keyword) == 0);
    }

    static bool IsEmpty(const std::string& result)
    {
        return (result.empty()) || (result == R"([{"result":""}])") || (result == R"([{"result":"null"}])");
    }
};


#endif //YACHTS_PGCLIENT_H
