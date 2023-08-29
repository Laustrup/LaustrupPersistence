package laustrup.persistence;

import lombok.Getter;

/**
 * Contains necessarily values for the database and are able to configure the values only at startup.
 * Gathers some values from Defaults as standard values.
 * Extends H2Config, that configures the embedded database used for testing purposes.
 */
public class DbLibrary {

    /**
     * Will be true, if the database has been initiated,
     * mostly useful with databases such as inmemory like H2.
     */
    private static boolean _hasInitiated;

    /**
     * The location of a script for initializing the database.
     * Is using it to insert it into the path.
     */
    private static String _initScriptLocation;

    /** Will allow a SQL statement to have multiple queries at once. */
    private static String _allowMultipleQueries;

    /** The location of the database. */
    private static String _location;

    /** The port of the database. */
    private static int _port;

    /** The schema that will be used of the database. */
    private static String _schema;

    /**
     * Determines if this DbLibrary has been configured yet,
     * it can only configure the values, if they aren't already configured
     */
    private boolean _setupIsConfigured = false;

    /** Value for the DbGate with the purpose of creating a connection. */
    @Getter
    private static String _path;
    @Getter
    private static String _user;
    @Getter
    private static String _password;
    private static Driver _driver;

    /**
     * Will change the fields of crating a connection for the database,
     * but only in case they haven't already been configured.
     * If fields are null, empty or integers are 0, they will not change the values.
     * @param location The location of the database.
     * @param port The port used for the schema.
     * @param schema The schema that is wished to use.
     * @param allowMultipleQueries If true, it will allow a single SQL statement
     *                             to be able to run multiple queries at once.
     * @param user The user for the database, that has rules for uses of the database.
     * @param password The password to insure the User has access permitted for the database.
     * @return A statement of the fields that has been updated,
     * if the configuration is not allowed, it will return that it wasn't.
     */
    public String setup(String location, int port, String schema,
                        boolean allowMultipleQueries, String user,
                        String password, Driver driver, Driver mode, String initScriptLocation) {
        boolean changeLocation = !(location == null || location.isEmpty()),
                changePort = port > 0,
                changeSchema = !(schema == null || schema.isEmpty()),
                changeUser = !(user == null || user.isEmpty()),
                changePassword = !(password == null || password.isEmpty()),
                allowConfiguration = !_setupIsConfigured;

        if (allowConfiguration) {
            _location = changeLocation ?  location : _location;
            _port = changePort ? port : _port;
            _schema = changeSchema ? schema : _schema;
            _allowMultipleQueries = !allowMultipleQueries ? "" : _allowMultipleQueries;
            _user = changeUser ? user : _user;
            _password = changePassword ? password : _password;
        }

        _driver = driver;
        _initScriptLocation = initScriptLocation;
        set_path(mode);
        _setupIsConfigured = true;

        if (allowConfiguration) {
            String fields = (changeLocation ? "Location\n" : "") +
                (changePort ? "Port\n" : "") +
                (changeSchema ? "Schema\n" : "") +
                (!allowMultipleQueries ? "Will not allow multiple queries\n" : "") +
                (changeUser ? "User\n" : "") +
                (changePassword ? "Password\n" : "");

            return "\tFields that has been successfully changed are:\n\n" + fields + "\n";
        }
        else
            return "\tConfigurations were not allowed...";
    }

    /**
     * Collects a string of a path to the database from the necessarily fields needed,
     * therefore the path should be set after location, port, schema and allow multiple queries.
     * Will generate or reset the reset_db.sql and it will be composed by the boilerplate.sql and default_values.sql.
     * @return The collected string.
     */
    public static String set_path() {
        return set_path(null);
    }

    public static String set_path(Driver mode) {
        String path =  "jdbc:" + _driver.get_pathName() +
            (isTesting()
                ? """
                  CACHE_SIZE=8192;DB_CLOSE_ON_EXIT=FALSE;AUTO_RECONNECT=TRUE;DB_CLOSE_DELAY=-1;@mode@init
                  """.replace("@mode", mode!=null ? "mode=" + mode.get_name() + ";" : "")
                     .replace("@init", !_hasInitiated && _initScriptLocation != null ? "INIT=RUNSCRIPT FROM '" + _initScriptLocation + "';" : "" )
                : "://" + _location + ":" + _port + "/" + _schema + _allowMultipleQueries
           );
        if (!_hasInitiated)
            _hasInitiated = true;

        return path;
    }

    /**
     * If at startup there isn't a wish for a different setup, this will use the default setup.
     * @return A message describing the setup is default.
     */
    public String defaultSetup() {
        _setupIsConfigured = true;
        return "Setup is default!";
    }

    /**
     * Simply checks if the driver is meant to be for testing purposes.
     * Testing purposes would be used for developing environment instead of production.
     * @return True if driver is H2 inmemory.
     */
    public static boolean isTesting() {
        return _driver == Driver.H2;
    }

}
