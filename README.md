## About RORM

RORM is a simple, light-weight object-relational mapping built in Ruby for SQLite3.
It aims to connect classes to relational database tables to establish an almost zero-configuration persistence layer for applications.

SQLObject classes mapping between a child class and a database table function as model in the MVC design pattern. RORM leverages this pattern to keep code dry and extends querying and association functionalities.
- A two-way mapping between Ruby model instances and database provides almost full support for normal CRUD operations
- The ability to run basic SQL queries using query methods
- Custom association generators with default parameters

## Setup
1. clone the repo to your local machine.  If you want to use RORM with your own database, you should start by customizing `lib/db_connection.rb` to point to your SQLite database files. The default is to point to the cat database included in the repo and referenced in the tests.  

2. run bundle install and pry.

3. try out associations and query methods.

### Associations

#### `belongs_to`

A belongs_to association sets up a one-to-one connection with another model, such that each instance of the declaring model "belongs to" one instance of the other model. RORM provides defaults so that when table and column names follow convention, additional parameters are not required.

#### `has_many`

A has_many association indicates a one-to-many connection with another model. You'll often find this association on the "other side" of a belongs_to association. This association indicates that each instance of the model has zero or more instances of another model.

### `through`

This association indicates that the declaring model can be matched with zero or more instances of another model by proceeding through a third model. RORM provides a generator for compounded associations: `has_one_through`, which create one-to-one associations.


### Query Methods

RORM implements query methods to minimize expensive and unnecessary database retrieval.

#### `all` and `count`

`::all` is equivalent to `SELECT * from [table_name]`.  It returns an array of model instances, each encoded with column names and values as instance variables.

`::count` is equivalent to `SELECT COUNT(*) from [table_name]` and returns the total number of records in the associated table.

#### `find`
`::find(id)` returns the record in the current table where `id`, an integer, matches the `primary_key`.

#### `where` and `where_not`
`::where(params_hash)` and `::where_not` take a series of one or more key-value pairs, mapping the keys (symbols) to equivalent column names, and inserting the values as parameters within the SQL query.

#### `first` and `last`

RORM also offers the convenience methods `::first` and `::last`, which return the first and last records in the associated table, by their `id` column.
