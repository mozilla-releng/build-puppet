ACL (Access Control List)
==============

####Table of Contents

1. [Overview - What is the acl module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with acl](#setup)
    * [Beginning with acl - Installation](#beginning-with-apache)
4. [Usage - The custom type available for configuration](#usage)
    * [Defined Type: acl](#defined-type-acl)
        * [Parameters](#parameters)
        * [Properties](#properties)
    * [Examples](#examples)
        * [Fully expressed ACL](#fully-expressed-acl)
        * [SID and FQDN](#sid-and-fqdn)
        * [Same target, multiple resources](#same-target-multiple-resources)
        * [Protect](#protect)
        * [Purge](#purge)
        * [Protect with purge](#protect-with-purge)
        * [ACE mask_specific rights](#ace-mask_specific-rights)
        * [Deny ACE](#deny-ace)
        * [ACE inheritance](#ace-inheritance)
        * [ACE propagation](#ace-propagation)
        * [Removing ACE permissions](#removing-ace-permissions)
        * [Same identity, multiple ACEs](#same-identity-multiple-aces)
5. [Limitations - Known issues in acl](#limitations)
6. [Development - Guide for contributing to the module](#development)


##Overview

The acl module uses Puppet to manage Access Control Lists on Windows.

##Module Description

The acl module adds a type and provider for managing permissions through Windows ACLs.

ACLs typically contain a list of access control entries (ACEs). An ACE is a defined trustee (identity) with a set of rights. For each ACE, the ACL contains an allowed/denied status, as well as the ACE's inheritance and propagation strategy. The order of ACEs within the ACL determines what allowed/denied status is applied first.

##Setup

The best way to install this module is by executing the following command on your puppet master or local Puppet install:

    $ puppet module install [--modulepath <path>] puppetlabs/acl

The above command also includes the optional argument to specify your puppet master's `modulepath` as the location to install the module.

###Beginning with acl

Each ACE has one of four possible statuses and the order you list the ACEs in is important for which status is applied first. The allow/deny types available are: 'explicit deny', 'explicit allow', 'inherited deny', and 'inherited allow'.

You cannot specify inherited ACEs in a manifest; you can only specify whether to allow upstream inheritance to flow into the managed target location (known as security descriptor). Please ensure your modeled resources follow this order or Windows will complain. The `acl` type **does not** enforce or complain about ACE order.

For a basic implementation of the acl module, you need to provide the target and at least one permission (access control entry or ACE). It will default the other settings to sensible defaults.

    acl { 'c:/tempperms':
      permissions => [
       { identity => 'Administrator', rights => ['full'] },
       { identity => 'Users', rights => ['read','execute'] }
     ],
    }

##Usage

###Defined Type: acl

The `acl` type contains two means of customization: [parameters](http://docs.puppetlabs.com/guides/custom_types.html#parameters) and [properties](http://docs.puppetlabs.com/guides/custom_types.html#properties). Parameters guide how the module operates. Properties guide ACL itself.

Below is an example of the `acl` type with all parameters and properties.

    acl { 'name':
      target => 'absolute/path',
      target_type => '<file>',
      purge => '<true| false | listed_permissions>',
      permissions => [
        { identity => '<identity>',
          rights => [<rights>],
          type => '<type>',
          affects => '<affects>',
          child_types => '<child_types>'
        }
        ],
      owner => '<owner>',
      group => '<group>',
      inherit_parent_permissions => '<true | false>',
    }

####Parameters

#####`name`

The name of the ACL resource; will be used for `target` if `target` is not set.

#####`purge`

Specifies whether to remove other explicit permissions if not specified in the `permissions` property. Valid values are 'true', 'false', and 'listed_permissions'. Default is 'false'.

You can use this parameter to ensure specific permissions are absent from the ACL with `purge => 'listed_permissions'`.

This parameter does not impact permissions inherited from parents. To remove parent permissions, combine `purge => 'false'` with `inherit_parent_permissions => 'false'`. **Note:** Be VERY careful when removing parent permissions, as it is possible to lock out Puppet from managing the resource, which will require manual intervention.

#####`target`

The location of the ACL resource. Defaults to `name` value. If you're using the first release of ACL, the value needs to be a file system location.

#####`target_type`

The type of target for the ACL resource. The only valid value is 'file'.

####Properties

#####`group`

The entity or entities that have access to a particular ACL descriptor. The group identity is also known as a trustee or principal. Valid inputs can be in the form of:

   * User - e.g. 'Bob' or 'TheNet\Bob'
   * Group - e.g. 'Administrators' or 'BUILTIN\Administrators'
   * SID (Security ID) - e.g. 'S-1-5-18'

No default value will be enforced by Puppet. Using the default will allow the group to stay set to whatever it is currently set to (group can vary depending on the original CREATOR GROUP). Since the identity must exist on the system in order to be used, Puppet will make sure they exist by creating them as needed.

**NOTE**: On Windows the CREATOR GROUP inherited ACE must be set for the creator's primary group to be set as an ACE automatically. Group is not always widely used. By default the group will also need to be specifically set as an explicit managed ACE. See [Microsoft's page](http://support.microsoft.com/kb/126629) for instructions on enabling CREATOR GROUP.

#####`inherit_parent_permissions`

Specifies whether to inherit permissions from parent ACLs. Valid values are 'true' and 'false'. Default is 'true'.

#####`owner`

The entity/entities that owns the particular ACL descriptor. The owner entity is also known as a trustee or principal. Valid inputs can be in the form of:

   * User - e.g. 'Bob' or 'TheNet\Bob'
   * Group e.g. 'Administrators' or 'BUILTIN\Administrators'
   * SID (Security ID) e.g. 'S-1-5-18'

No default value will be enforced by Puppet. Using the default will allow the owner to stay set to whatever it is currently set to (owner can vary depending on the original CREATOR OWNER). Since the identity must exist on the system in order to be used, Puppet will make sure they exist by creating them as needed.

#####`permissions`

An array containing Access Control Entries (ACEs). The ACEs must be in explicit order. The elements must be presented in a hash that minimally requires `identity` and `rights` values.

```
…
permissions => [
    { identity => 'Administrators', rights => ['full'] }
]
```
The available elements in the hash are: `identity`, `rights`, `type`, `child_types`, `affects`, and `mask`. The `mask` entry should only be specified with `rights => ['mask_specific']`. For instance,

```
…
permissions => [
    { identity => 'Administrators', rights => ['full'], type=> 'allow', child_types => 'all', affects => 'all' }
]
```

Each permission (ACE) is determined to be unique based on `identity`, `type`, `child_types`, and `affects`. While you can technically create more than one ACE that differs from other ACEs only in rights, acl module is not able to tell the difference between those so it will appear that the resource is out of sync every run when it is not.

While you will see `is_inherited => 'true'` when running `puppet resource acl some_path`, puppet will not be able to manage the inherited permissions so those will need to be removed if using that to build a manifest.

**Elements in `permissions`**

  * `identity` is a group, user, or SID. It must exist on the system and will auto-require on user and group resources. `identity` can be in the form of:
    * User - e.g. 'Bob' or 'TheNet\Bob'
    * Group e.g. 'Administrators' or 'BUILTIN\Administrators'
    * SID (Security ID) e.g. 'S-1-5-18'
  * `rights` is an array that can have the following values: 'full', 'modify', 'mask_specific', 'write', 'read', and 'execute'. The 'full', 'modify', and 'mask_specific' values are mutually exclusive and must be the *only* value specified in `rights`. The 'full' value indicates all rights. The 'modify' value is cumulative, implying 'write', 'read', 'execute' *and* DELETE all in one. If you specify 'full' or 'modify' as part of a set of rights with other rights, e.g. `rights => ['full','read']`, the `acl` type will issue a warning and remove the other items. You can specify any combination of 'write', 'read', and 'execute'. If you specify 'mask_specific', you must also specify the `mask` element in the `permissions` hash with an [integer](http://msdn.microsoft.com/en-us/library/aa394063(v=vs.85).aspx) passed as a string.

```
acl { 'c:/tempperms':
      permissions => [
       { identity => 'Administrators', rights => ['full'] },
       { identity => 'Administrator', rights => ['modify'] },
       { identity => 'Authenticated Users', rights => ['write','read','execute'] },
       { identity => 'Users', rights => ['read','execute'] }
       { identity => 'Everyone', rights => ['read'] }
      ],
      inherit_parent_permissions => 'false',
    }
```

  * `mask` is an element that only works if 'mask_specific' is set in the `rights` element. The value must be an [integer representing mask permissions](http://msdn.microsoft.com/en-us/library/aa394063(v=vs.85).aspx) passed in a string.
  * `type` can be 'allow' or 'deny', and defaults to 'allow'.
  * `child_types` determines how an ACE is inherited downstream from the target. Valid values are 'all', 'objects', 'containers' or 'none'. Defaults to 'all'.
  * `affects` determines how the downstream inheritance is propagated. Valid values are 'all', 'self_only', 'children_only', 'self_and_direct_children_only', or 'direct_children_only'. Defaults to 'all'.

###Examples

####Fully expressed ACL

The fully expressed ACL in the sample below produces the same settings as the [minimal sample](beginning-with-acl) in the Setup section.

```
    acl { 'c:/tempperms':
      target      => 'c:/tempperms',
      target_type => 'file',
      purge       => 'false',
      permissions => [
       { identity => 'Administrator', rights => ['full'], type=> 'allow', child_types => 'all', affects => 'all' },
       { identity => 'Users', rights => ['read','execute'], type=> 'allow', child_types => 'all', affects => 'all' }
      ],
      owner       => 'Administrators', #Creator_Owner specific, doesn't manage unless specified
      group       => 'Users', #Creator_Group specific, doesn't manage unless specified
      inherit_parent_permissions => 'true',
    }
```

####SID/FQDN
Users can be specified with [SIDs](http://support.microsoft.com/kb/243330) (Security Identifiers) or as fully qualified domain names (FQDN).

```
    acl { 'c:/tempperms':
      permissions => [
       { identity => 'NT AUTHORITY\SYSTEM', rights => ['modify'] },
       { identity => 'BUILTIN\Users', rights => ['read','execute'] },
       { identity => 'S-1-5-32-544', rights => ['write','read','execute'] }
      ],
    }
```

####Same target, multiple resources

You can manage the same target across multiple ACL resources with some caveats: the title of the resource needs to be unique, and you should only do so when you absolutely need to since it can get confusing quickly.

You should not set `purge => 'true'` on any of the resources that apply to the same target or you will see thrashing in reports, as the permissions will be added and removed on every catalog application. **Use this feature with care.**

```
    acl { 'c:/tempperms':
      permissions => [
       { identity => 'Administrator', rights => ['full'] }
     ],
    }

    acl { 'tempperms_Users':
      target      => 'c:/tempperms',
      permissions => [
       { identity => 'Users', rights => ['read','execute'] }
     ],
    }
```

####Protect

Removing upstream inheritance is known as protecting the target. When an item is protected without `purge => true`, the inherited ACEs will be copied into the target as unmanaged ACEs.

```
    acl { 'c:/tempperms':
      permissions => [
       { identity => 'Administrators', rights => ['full'] },
       { identity => 'Users', rights => ['full'] }
      ],
      inherit_parent_permissions => 'false',
    }
```

####Purge

You cannot purge inherited permissions; you can only purge explicit permissions. To lock down a folder to managed explicit ACEs, you want to set `purge => true`. This will only remove other explicit ACEs from the folder that are unmanaged by this resource. All inherited ACEs will remain (see next example).

```
    acl { 'c:/tempperms':
      purge       => 'true',
      permissions => [
       { identity => 'Administrators', rights => ['full'] },
       { identity => 'Users', rights => ['full'] }
      ],
    }
```

####Protect with purge

To lock down a folder and only allow the permissions specified explicitly in the manifest resource, you want to protect the folder and set `purge => 'true'`.

**Warning**: While managing ACLs, you can completely lock the user running Puppet out of managing resources. Extreme care should be taken when using `purge => true` with `inherit_parent_permissions => false` in the `acl` type. If Puppet is locked out of managing the resource, manual intervention on affected nodes will be required.

```
    acl { 'c:/tempperms':
      purge       => 'true',
      permissions => [
       { identity => 'Administrators', rights => ['full'] },
       { identity => 'Users', rights => ['full'] }
      ],
      inherit_parent_permissions => 'false',
    }
```

####ACE mask_specific rights

Enabling `rights => ['mask_specific']` indicates that rights are passed as part of an ACE mask, so the mask is all that will be evaluated. In these cases you must also specify 'mask' with an integer (passed as a string) that represents the permissions mask. You must not combine values, such as read permissions, with the mask. The `acl` provider will error if you attempt to do this.

**NOTE:** 'mask_specific' should ONLY be used when other rights are not specific enough. If you specify 'mask_specific' with the equivalent of 'full' rights (2032127), and it finds the property to be 'full', it will report making changes to the resource even though nothing is different.

```
    acl { 'c:/tempperms':
      purge       => 'true',
      permissions => [
       { identity => 'Administrators', rights => ['full'] }, #full is same as - 2032127 aka 0x1f01ff but you should use 'full'
       { identity => 'SYSTEM', rights => ['modify'] }, #modify is same as 1245631 aka 0x1301bf but you should use 'modify'
       { identity => 'Users', rights => ['mask_specific'], mask => '1180073' }, #RX WA #0x1201a9
       { identity => 'Administrator', rights => ['mask_specific'], mask => '1180032' }  #RA,S,WA,Rc #1180032  #0x120180
      ],
      inherit_parent_permissions => 'false',
    }
```

**References**

 * File/Directory Access Mask Constants - http://msdn.microsoft.com/en-us/library/aa394063(v=vs.85).aspx
 * File Generic Access Rights - http://msdn.microsoft.com/en-us/library/windows/desktop/aa364399(v=vs.85).aspx
 * Access Mask Format - http://msdn.microsoft.com/en-us/library/windows/desktop/aa374896(v=vs.85).aspx


####Deny ACE

ACEs can be of `type` 'allow' or 'deny'. Deny ACEs should be listed first before allow ACEs.

```
    acl { 'c:/tempperms':
      permissions => [
       { identity => 'SYSTEM', rights => ['full'], type=> 'deny', affects => 'self_only' },
       { identity => 'Administrators', rights => ['full'] }
      ],
    }
```

####ACE inheritance

ACEs have inheritance structures controlled by [`child_types`](#permissions), which determine how sub-folders and files will inherit each particular ACE.

```
    acl { 'c:/tempperms':
      purge       => 'true',
      permissions => [
       { identity => 'SYSTEM', rights => ['full'], child_types => 'all' },
       { identity => 'Administrators', rights => ['full'], child_types => 'containers' },
       { identity => 'Administrator', rights => ['full'], child_types => 'objects' },
       { identity => 'Users', rights => ['full'], child_types => 'none' }
      ],
      inherit_parent_permissions => 'false',
    }
```

####ACE propagation

ACEs have propagation rules which guide how they apply permissions to containers, objects, children and grandchildren. Propagation is determined by [`affects`](#permissions), which can take the value of: 'all', 'self_only', 'children_only', 'direct_children_only', and 'self_and_direct_children_only'. Microsoft has a [good matrix](http://msdn.microsoft.com/en-us/library/ms229747.aspx) that outlines when and why you might use each of these values.

```
    acl { 'c:/tempperms':
      purge       => 'true',
      permissions => [
       { identity => 'Administrators', rights => ['modify'], affects => 'all' },
       { identity => 'Administrators', rights => ['full'], affects => 'self_only' },
       { identity => 'Administrator', rights => ['full'], affects => 'direct_children_only' },
       { identity => 'Users', rights => ['full'], affects => 'children_only' },
       { identity => 'Authenticated Users', rights => ['read'], affects => 'self_and_direct_children_only' }
      ],
      inherit_parent_permissions => 'false',
    }
```

####Removing ACE permissions

Removing permissions is done by using `purge => listed_permissions`. This will remove explicit permissions from the ACL. When the example below is done, it will ensure that 'Administrator' and 'Authenticated Users' are not on the ACL. This comparison is done based on `identity`, `type`, `child_types` and `affects`.

```
    #set permissions
    acl { 'c:/tempperms/remove':
      purge       => 'true',
      permissions => [
       { identity => 'Administrators', rights => ['full'] },
       { identity => 'Administrator', rights => ['write'] },
       { identity => 'Users', rights => ['write','execute'] },
       { identity => 'Everyone', rights => ['execute'] },
       { identity => 'Authenticated Users', rights => ['full'] }
      ],
      inherit_parent_permissions => 'false',
    }

    #now remove some permissions
    acl { 'remove_tempperms/remove':
      target      => 'c:/tempperms/remove',
      purge       => 'listed_permissions',
      permissions => [
       { identity => 'Administrator', rights => ['write'] },
       { identity => 'Authenticated Users', rights => ['full'] }
      ],
      inherit_parent_permissions => 'false',
      require     => Acl['c:/tempperms/remove'],
    }
```

####Same identity, multiple ACEs

With Windows, you can specify the same `identity` with different inheritance and propagation and each of those items will actually be managed as separate ACEs.

```
    acl { 'c:/tempperms':
      purge       => 'true',
      permissions => [
       { identity => 'SYSTEM', rights => ['modify'], child_types => 'none' },
       { identity => 'SYSTEM', rights => ['modify'], child_types => 'containers' },
       { identity => 'SYSTEM', rights => ['modify'], child_types => 'objects' },
       { identity => 'SYSTEM', rights => ['full'], affects => 'self_only' },
       { identity => 'SYSTEM', rights => ['read','execute'], affects => 'direct_children_only' },
       { identity => 'SYSTEM', rights => ['read','execute'], child_types=>'containers', affects => 'direct_children_only' },
       { identity => 'SYSTEM', rights => ['read','execute'], child_types=>'objects', affects => 'direct_children_only' },
       { identity => 'SYSTEM', rights => ['full'], affects => 'children_only' },
       { identity => 'SYSTEM', rights => ['full'], child_types=>'containers', affects => 'children_only' },
       { identity => 'SYSTEM', rights => ['full'], child_types=>'objects', affects => 'children_only' },
       { identity => 'SYSTEM', rights => ['read'], affects => 'self_and_direct_children_only' },
       { identity => 'SYSTEM', rights => ['read'], child_types=>'containers', affects => 'self_and_direct_children_only' },
       { identity => 'SYSTEM', rights => ['read'], child_types=>'objects', affects => 'self_and_direct_children_only' }
      ],
      inherit_parent_permissions => 'false',
    }
```

##Limitations

 * The Windows Provider in the first release (at least) will not handle permissions with Symlinks. Please explicitly manage the permissions of the target.
 * Each permission (ACE) is determined to be unique based on `identity`, `type`, `child_types`, and `affects`. While you can technically create more than one ACE that differs from other ACEs only in `rights`, the acl module is not able to tell the difference between those, so it will appear that the resource is out of sync every run when it is not.

```
  !!!DO NOT DO THIS!!!
  acl { 'c:/tempperms':
      permissions => [
       { identity => 'SYSTEM', rights => ['full']},
       { identity => 'SYSTEM', rights => ['read']}
     ],
    }
  !!!SERIOUSLY, DON'T DO THIS.
```
 * Windows 8.3 short name format for files/directories is not supported.
 * Using Cygwin to run puppet with ACLs could result in undesirable behavior (on Windows 2008 'Administrator' identity might be translated to 'cyg_server', but may behave fine on other systems like Windows 2012). We wouldn't recommend using Cygwin to run Puppet with ACL manifests due to this and other possible edge cases. This tends to happen when using Cygwin SSHD with public key authentication.
 * Unicode for identities, group, and owner may not work appropriately or at all in the first release.
 * When using SIDs for identities, autorequire will attempt to match to users with fully qualified names (User[BUILTIN\Administrators]) in addition to SIDs (User[S-1-5-32-544]). The limitation is that it won't match against 'User[Administrators]' as that could cause issues if attempting to match domain accounts versus local accounts with the same name e.g. 'Domain\Bob' vs 'LOCAL\Bob'.

Please log tickets and issues at our [Module Issue Tracker](https://tickets.puppetlabs.com/browse/MODULES).

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

Licensed under [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)