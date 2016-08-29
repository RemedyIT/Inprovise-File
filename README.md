
Inprovise File dependency
=========================

This project implements an extension for the Inprovise provisioning tool providing a `file` command to the basic
Inprovise scripts.

Installation
------------

    $ gem install inprovise-file

Usage
-----

Add the following to (for example) your Inprovise project's `rigrc` file.

````ruby
require 'inprovise/file'
````

Syntax
------

````ruby
file({
  :source       => '/local/source/path',        # alternatively provide block returning path string
  :destination  => '/remote/destination/path',  # alternatively provide block returning path string
  :create_dirs  => true,                        # alternatively provide block returning boolean
  :permissions  => 0644,                        # alternatively provide block returning permissions
  :group        => 'users',                     # alternatively provide block returning group id
  :user         => 'userid'                     # alternatively provide block returning user id
}) [ do ... end]                                # optional action block
````

or

````ruby
file({
  :template     => '/local/template/path',      # alternatively provide block returning inline ERB template
  :destination  => '/remote/destination/path',  # alternatively provide block returning path string
  :create_dirs  => true,                        # alternatively provide block returning boolean
  :permissions  => 0644,                        # alternatively provide block returning permissions
  :group        => 'users',                     # alternatively provide block returning group id
  :user         => 'userid'                     # alternatively provide block returning user id
}) [ do ... end]                                # optional action block
````

Providing `:source` and `:destination` is mandatory.
All other settings are optional. 
