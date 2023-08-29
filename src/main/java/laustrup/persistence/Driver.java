package laustrup.persistence;

import lombok.Getter;

/**
 * An enum that contains different values with properties assigned to them.
 * The different values are the different types of databases available.
 */
public enum Driver {

    /** The driver value with name, pathName and className of MySQL that can be used to initialize MySQL at Repository. */
    MySQL("MySQL","mysql","com.mysql.cj.jdbc.Driver"),
    /** The driver value with name, pathName and className of PostGreSQL that can be used to initialize PostGreSQL at Repository. */
    POSTGRESQL("PostGreSQL","postgresql","org.postgresql.Driver"),
    /** The driver value with name, pathName and className of H2 that can be used to initialize H2 at Repository. */
    H2("H2","h2:mem:TESTING","org.h2.Driver");

    /**
     * The name property of a Driver enum value.
     * Is used to referer to the specific driver type.
     * Usually written as it is pretended, like MySQL, PostGreSQL or H2.
     */
    @Getter
    private final String _name;

    /**
     * The path name property of a Driver enum value.
     * Is used to define the name used for creating a path, like a connection.
     */
    @Getter
    private final String _pathName;

    /**
     * The class name property of a Driver enum value.
     * Contains the name of the driver java class, that will be needed to be defined.
     */
    @Getter
    private final String _className;

    Driver(String name, String pathName, String className) {
        _name = name;
        _pathName = pathName;
        _className = className;
    }
}
