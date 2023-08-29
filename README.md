# Laustrup Persistence

### Description

Uses C# _ as syntax for attributes.

This project contains Java classes, that can be used to simplify JDBC actions and avoid redundancy.

All that would be needed is writing SQLs to the right action and remember closing the connection after use.

Currently MySQL, PostGreSQL and for testing an in memory H2 database, are the drivers available to be used.
## Classes

There are two classes available publicly:

* #### Repository
  This is the main purpose class of this project.

  When it is being extended, it can perform various CRUD actions, by simply writing SQL in the input.

  An example:

  ```
  public class ExampleRepository extends Repository {
      public ResultSet create(Point point) {
          return create(
              """
              INSERT INTO `points`(`id`,`content`,`timestamp`) VALUES('@id', '@content', '@timestamp')
              """.replace("@id", point.getId())
                 .replace("@content", point.getContent())
                 .replace("@timestamp", point.getTimestamp())
          );
      }
  
      public ResultSet getPoint(long id) {
          return read("SELECT * FROM `points` WHERE `id` = " + id + ";");
      }
  
      // Closes connetion
      public boolean update(Point point) {
          return edit(
              """
              UPDATE `points` `content` = @content WHERE `id` = @id;
              """.replace("@content", point.getContent())
                 .replace("@id", point.getId())
          );
      }
  
      // Closes connection if the last argument is true
      public boolean delete(Point point) {
          return delete(point.getId(),"`points`","`id`",true);
      }
  }
  ```

  Before each action, the connection will be created, in case it isn't already open, in that case it reuses that connection.

  Remember to check if the actions needs to close connection after use. This class can close it.


* #### DbLibrary
  Simply contains all the necessarily values needed for the database such as connection attributes.

  This is also where the configuring of the database is needed, call the DbLibrary.setup() and fill in the input fields as the first thing in the main method.