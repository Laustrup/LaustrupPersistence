package laustrup.persistence;

import laustrup.utilities.console.Printer;
import laustrup.utilities.parameters.Plato;

import lombok.Getter;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

class DbGate {

//    /**
//     * Singleton instance of the DbGate.
//     */
//    private static DbGate _instance = null;
//
//    /**
//     * Checks first if instance is null, otherwise will create a new instance of the object.
//     * Created as a lazyfetch.
//     * @return The instance of the object, as meant as a singleton.
//     */
//    public static DbGate get_instance() {
//        if (_instance == null) _instance = new DbGate();
//        return _instance;
//    }

    /**
     * This is the only connection to the database, that is to be used.
     */
    @Getter
    private static Connection _connection;

    private DbGate() {}

    /**
     * Will open connection.
     * @return True if the connection could open, otherwise false.
     */
    public static boolean open() {
        if (_connection == null)
            return createConnection();
        else if (isClosed().get_truth())
            return createConnection();

        return false;
    }

    /**
     * Creates a connection from DriverManager.
     * @return True if the connection is open and haven't caught any exceptions.
     */
    private static boolean createConnection() {
        if (isClosed().get_truth()) {
            try {
                _connection = DriverManager.getConnection(DbLibrary.get_path(), DbLibrary.get_user(), DbLibrary.get_password());
                return isOpen().get_truth();
            } catch (SQLException e) {
                Printer.get_instance().print(
                    """
                    Couldn't open connection with:
                    
                    path: "@path"
                    user: "@user"

                    If these values seem right, perhaps password might be wrong...
                    """
                    .replace("@path",DbLibrary.get_path())
                    .replace("@user",DbLibrary.get_user())
                        ,e
                );
            }
        } else
            Printer.get_instance().print(
                "Connection " + _connection + " to database seems to be already open!",
                new Exception("There is already a Connection to the database with JDBC, therefore DbGate didn't create a new one...")
            );

        return false;
    }

    /**
     * Will close Connection but only if it already is open.
     * In case the Connection is null, nothing will happen.
     * @return The success of the closing as a Plato. Will be undefined, if there is a SQLException and null if the connection is null.
     */
    public static Plato close() {
        if (_connection != null) {
            try {
                if (isOpen().get_truth()) {
                    _connection.close();
                    return new Plato(true);
                } else
                    Printer.get_instance().print(
                        "Connection " + _connection + "to database seems to be already closed...",
                        new Exception("There isn't current any Connection to the database with JDBC, therefore DbGate didn't close any...")
                    );
            } catch (SQLException e) {
                Printer.get_instance().print("Couldn't close connection...",e);
                Plato plato = new Plato();
                plato.set_message("Couldn't close connection...");
                return plato;
            }
        }

        return null;
    }

    /**
     * Determine whether the connection is open.
     * @return True if it is open, false if it is closed.
     */
    public static Plato isOpen() {
        return new Plato(!isClosed().get_truth());
    }

    /**
     * Determine whether the connection is closed.
     * @return True if it is closed, false if it is open.
     */
    public static Plato isClosed() {
        try {
            return new Plato(_connection.isClosed());
        } catch (SQLException e) {
            Printer.get_instance().print("Trouble determine if the connection is closed...",e);
        }
        return new Plato();
    }

    /**
     * Determines whether the connection is null or not.
     * @return _connection == null;
     */
    public static boolean connectionIsNull() {
        return _connection == null;
    }
}
