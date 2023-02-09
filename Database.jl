module Database

using MySQL

const HOST = "localhost"
const USER = "root"
const PASS = "SomePassword"
const DB = "six_degrees"

const CONN = DBInterface.connect(MySQL.Connection, HOST, USER, PASS, db=DB, unix_socket="/var/run/mysqld/mysqld.sock")

export CONN

disconnect() = DBInterface.close!(CONN)
atexit(disconnect)

end