cmake_minimum_required(VERSION 3.17)
project(yachts)

set(CMAKE_CXX_STANDARD 17)

add_executable(yachts main.cpp PGClient.h HTTPServer.h)

target_link_libraries(yachts pq)
target_link_libraries(yachts pqxx)
target_link_libraries(yachts pthread)