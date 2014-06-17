## 0.1.8 / 2014-06-17

* catch Mysql2 errors
* remove dubious return from ensure in activerecord extensions

## 0.1.5 / 2014-03-10

* Make sure to raise when uniq_find_or_create cannot find a record

## 0.1.4 / 2014-02-25

* Add ActiveRecord \#uniq\_find\_or\_create\_by! method to find or create records with uniqueness constraints enforced by the database.
* Add some clarifying comments to the ActiveRecord extensions.

## 0.1.3 / 2014-02-24

* Add ActiveRecord \#uniq\_find\_or\_create\_by method to find or create records with uniqueness constraints enforced by the database.

## 0.1.2.1

* Bugfixes for Errors.

## 0.1.2

* Added `Roqua::Support::Errors.report(exception, extra_info = {})` which sends exception to all configured exception notifiers

## 0.1.1

Here be dragons
