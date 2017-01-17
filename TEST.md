# Setting up Development environment in Archlinux

## Needed
* Ruby version is strict, trying 2.2.6 via rvm as this is also the version installed in my docker image. Archlinux has 2.4.0
* Cannot find command 'unp', installed unp
* ogr2ogr looks for binary named ogr2ogr2.1, needed to be changed in app_config.yml to ogr2ogr for Archlinux development
* test relies on the ability to start a redis server on the local machine, installed redis in Archlinux without issues

## Minor flaws
* Dimensions for the svg test file look slightly wrong. Changed manually
* A test to find unused ports tries to use netstat. Not available on my Archlinux.
* Cannot find command 'unp'

# Undetected errors
viewer users
    can't create new data imports

CartoDB::Visualization::NameChecker
  #available?
    returns true if passed visualization name is available for the user
    returns false if passed visualization name is in use by the user
    returns true if name is available but used in shared visualizations

    An error occurred in an after(:all) hook.
      NoMethodError: undefined method `destroy' for #<CartoDB::Visualization::Member:0x0000000e5e6600>
      occurred at /home/miblon/NetBeansProjects/cartodb/spec/models/visualization/name_checker_spec.rb:31:in `block (2 levels) in <top (required)>'


An error occurred in an after(:all) hook.
  NoMethodError: undefined method `destroy' for nil:NilClass
  occurred at /home/miblon/NetBeansProjects/cartodb/spec/models/data_import_spec.rb:14:in `block (2 levels) in <top (required)>'

# Detected
Map
  should correcly set vizjson updated_at
  viewer role support
    #validations
      #options
        requires dashboard_menu to be present (FAILED - 1)
        requires layer_selector to be present (FAILED - 2)
        rejects incomplete options (FAILED - 3)

Carto::Api::UserPresenter
  Compares old and new ways of 'presenting' user data (FAILED - 7)
