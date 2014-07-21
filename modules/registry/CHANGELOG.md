##2014-03-04 - Supported Release 1.0.0
###Summary
This is a supported release.

####Bugfixes
- Documentation updates
- Add license file

####Known Bugs

* This module does not work if run as non-root. Please see [PE-2772](https://tickets.puppetlabs.com/browse/PE-2772)

---

##2013-08-01 - Release 0.1.2
###Summary:
This is a bugfix release that allows the module to work more reliably on x64
systems and on older systems such as 2003. Also fixes compilation errors due
to windows library loading on *nix masters.

####Bugfixes:
- Refactored code into PuppetX namespace
- Fixed unhandled exception when loading windows code on *nix
- Updated README and manifest documentation
- Only manage redirected keys on 64 bit systems
- Only use /sysnative filesystem when available
- Use class accessor method instead of class instance variable
- Add geppetto project file

---

##### 2012-05-21 - 0.1.1 - Jeff McCune <jeff@puppetlabs.com>

 * (#14517) Improve error handling when writing values (27223db)
 * (#14572) Fix management of the default value (f29bdc5)

##### 2012-05-16 - 0.1.0 - Jeff McCune <jeff@puppetlabs.com>

 * (#14529) Add registry::value defined type (bf44208)

##### 2012-05-16 - Josh Cooper <josh+github@puppetlabs.com>
 
 * Update README.markdown (2e9e45e)

##### 2012-05-16 - Josh Cooper <josh+github@puppetlabs.com>
 
 * Update README.markdown (3904838)

##### 2012-05-15 - Josh Cooper <josh@puppetlabs.com>
 
 * (Maint) Add type documentation (82205ad)

##### 2012-05-15 - Josh Cooper <josh+github@puppetlabs.com>

 * Remove note about case-sensitivity, as that is no longer an issue (5440a0e)

##### 2012-05-15 - Jeff McCune <jeff@puppetlabs.com>
 
 * (#14501) Fix autorequire case sensitivity (d5c12f0)

##### 2012-05-15 - Jeff McCune <jeff@puppetlabs.com>
 
 * (maint) Remove RegistryKeyPath#{valuename,default?} methods (29db478)

##### 2012-05-14 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add acceptance tests for registry_value provider (6285f4a)

##### 2012-05-14 - Jeff McCune <jeff@puppetlabs.com>
 
 * Eliminate RegistryPathBas#(default?,valuename) from base class (2234f96)

##### 2012-05-14 - Jeff McCune <jeff@puppetlabs.com>
  
  * Memoize the filter_path method for performance (6139b7d)

##### 2012-05-11 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add Registry_key ensure => absent and purge_values coverage (cfd3789)

##### 2012-05-11 - Jeff McCune <jeff@puppetlabs.com>
 
 * Fix cannot alias error when managing 32 and 64 bit versions of a key (3a2f260)

##### 2012-05-11 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add registry_key creation acceptance test (0e68654)

##### 2012-05-09 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add acceptance tests for the registry type (0a01b11)

##### 2012-05-08 - Jeff McCune <jeff@puppetlabs.com>
 
 * Update type description strings (c69bf2d)

##### 2012-05-05 - Jeff McCune <jeff@puppetlabs.com>
 
 * Separate the implementation of the type and provider (4e06ae5)

##### 2012-05-04 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add watchr script to automatically run tests (d5bce2d)

##### 2012-05-04 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add registry::compliance_example class to test compliance (0aa8a68)

##### 2012-05-03 - Jeff McCune <jeff@puppetlabs.com>

 * Allow values associated with a registry key to be purged (27eaee3)

##### 2012-05-01 - Jeff McCune <jeff@puppetlabs.com>
 
 * Update README with info about the types provided (b9b2d11)

##### 2012-04-30 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add registry::service defined resource example (57c5b59)

##### 2012-04-25 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add REG_MULTI_SZ (type => array) implementation (1b17c6f)

##### 2012-04-26 - Jeff McCune <jeff@puppetlabs.com>
 
 * Work around #3947, #4248, #14073; load our utility code (a8d9402)

##### 2012-04-24 - Josh Cooper <josh@puppetlabs.com>
 
 * Handle binary registry values (4353642)

##### 2012-04-24 - Josh Cooper <josh@puppetlabs.com>
 
 * Fix puppet resource registry_key (f736cff)

##### 2012-04-23 - Josh Cooper <josh@puppetlabs.com>
 
 * Registry keys and values were autorequiring all ancestors (0de7a0a)

##### 2012-04-24 - Jeff McCune <jeff@puppetlabs.com>
 
 * Add examples of current registry key and value types (bb7e4f4)

##### 2012-04-23 - Josh Cooper <josh@puppetlabs.com>
 
 * Add the ability to manage 32 and 64-bit keys/values (9a16a9b)

##### 2012-04-23 - Josh Cooper <josh@puppetlabs.com>
 
 * Remove rspec deprecation warning (94063d5)

##### 2012-04-23 - Josh Cooper <josh@puppetlabs.com>
 
 * Rename registry-specific util code (cd2aaa1)

##### 2012-04-20 - Josh Cooper <josh@puppetlabs.com>
 
 * Fix autorequiring when using different root key forms (b7a1c39)

##### 2012-04-19 - Josh Cooper <josh@puppetlabs.com>

 * Refactor key and value paths (74ebc80)

##### 2012-04-19 - Josh Cooper <josh@puppetlabs.com>

 * Encode default-ness in the registry path (64bba67)

##### 2012-04-19 - Josh Cooper <josh@puppetlabs.com>

 * Better validation and testing of key paths (d05d1e6)

##### 2012-04-19 - Josh Cooper <josh@puppetlabs.com>

 * Maint: Remove more crlf line endings (e9f00c1)

##### 2012-04-19 - Josh Cooper <josh@puppetlabs.com>
 
 * Maint: remove windows cr line endings (0138a1d)

##### 2012-04-18 - Josh Cooper <josh@puppetlabs.com>
 
 * Rename `default` parameter (f45af86)

##### 2012-04-18 - Josh Cooper <josh@puppetlabs.com>
 
 * Fix modifying existing registry values (d06be98)

##### 2012-04-18 - Josh Cooper <josh@puppetlabs.com>
 
 * Remove debugging (8601e92)

##### 2012-04-18 - Josh Cooper <josh@puppetlabs.com>
 
 * Always split the path (de66832)

##### 2012-04-18 - Josh Cooper <josh@puppetlabs.com>
 
 * Initial registry key and value types and providers (065d43d)
