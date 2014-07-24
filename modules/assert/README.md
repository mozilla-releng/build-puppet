Introduction
============

Sometimes you find yourself in a situation where you may want to verify
a condition before including a class, or similar. Perhaps you have custom
facts that are only set after pluginsync is enabled, but you can't enable
pluginsync until a puppet run manages `puppet.conf`. This resource type
allows you to specify an assert clause, and any dependencies of this
resource will be skipped if the assert fails.

Remember that puppet handles undefined variables as `undef` which evaluates
to `false`. This means that you can simply assert on a custom fact and it
will fail if that fact does not exist.

You can temporarily disable an assert by setting its ensure parameter to absent.

Usage
=======

    assert { 'This should be applied':
      condition => true
    } -> 
    class { 'two': }
    
    assert { 'This should NOT be applied':
      condition => false
    } -> 
    class { 'three': }
    
    assert { 'This should be applied':
      ensure => absent,
      condition => false
    } -> 
    class { 'four': }


Contact
=======

* Author: Ben Ford
* Email: ben.ford@puppetlabs.com
* Twitter: @binford2k
* IRC (Freenode): binford2k

Credit
=======

The development of this code was sponsored by Coverity.

License
=======

Copyright (c) 2012 Puppet Labs, info@puppetlabs.com  
Copyright (c) 2012 Coverity.com, mllaguno@coverity.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.