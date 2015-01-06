## 0.1.19

* Add active_interaction/rails_instrumentation

## 0.1.18

* Fix default stats backend

## 0.1.17 / 2014-11-20

* Add support for Hosted Graphite through Roqua.stats
* Deprecate Roqua::Logging in favor of Roqua::Support::Instrumentation

## 0.1.16 / 2014-11-19

* Add support for skipping the backtrace in the logs

## 0.1.15 / 2014-11-18

* log Airbrake UUID when reporting exceptions

## 0.1.14 / 2014-11-13

* Don't put request data under params
* Robustify reporting exceptions

## 0.1.13 / 2014-11-12

* Add support for reporting request data to Airbrake

## 0.1.12 / 2014-11-10

* Added roqua/core_ext/active_interaction/filters/date_time_as_unix_extension that allows date_times attributes to be set by a unix timestamp.
* Added roqua/core_ext/active_interaction/filters/duration_filter that allows ActiveSupport::Duration attributes.

## 0.1.11 / 2014-11-06

* Don't catch Mysql2 errors

## 0.1.10 / 2014-10-30

* Added ActiveInteractionAwareResponder
* Added ApiErrorsResponder

## 0.1.9 / 2014-06-18

* add Fabricate.clear_singletons! utility method

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
