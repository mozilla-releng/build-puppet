# == Class: acl
#
# Manages access control lists (ACLs).  The `acl` type is
# typically used when you need more complex management of
# permissions e.g. Windows. ACLs typically contain access
# control entries (ACEs) that define a trustee (identity)
# with a set of rights, whether the type is allow or deny,
# and how inheritance and propagation of those ACEs are
# applied to the resource target and child types under it.
# The order that ACEs are listed in is important on Windows
# as it determines what is applied first.
#
# Order of ACE application on Windows is explicit deny,
# explicit allow, inherited deny, then inherited allow. You
# cannot specify inherited ACEs in a manifest, only whether
# to allow upstream inheritance to flow into the managed
# target location (known as security descriptor). Please
# ensure your modeled resources follow this order or Windows
# will complain. NOTE: `acl` type does not enforce or
# complain about ACE order.
#
# For very specific examples, see the readme[1] and learn
# about the different features of the `acl` type.
# [1] https://github.com/puppetlabs/puppetlabs-acl/blob/master/README.md
#
# **Autorequires:** If Puppet is managing the user, group or
# target of an acl resource, the acl type will autorequire
# them.
#
# === Parameters
#
# [*name*]
#   The name of the acl resource. Used for uniqueness. Will set
#   the target to this value if target is unset.
#
# [*target*]
#   The location the acl resource is pointing to. In the first
#   release of ACL, this will be a file system location.
#   The default is the name.
#
# [*target_type*]
#   The type of target for the Acl resource. In the first release
#   of ACL, only `file` is allowed. Defaults to `file`.
#   Valid values are `file`.
#
# [*purge*]
#   Purge specifies whether to remove other explicit permissions
#   if not specified in the permissions set. This doesn't do anything
#   with permissions inherited from parents (to remove those you should
#   combine `purge => 'false', inherit_parent_permissions => 'false'`.
#   This also allows you to ensure the permissions listed are not on
#   the ACL with `purge => 'listed_permissions'`.
#   The default is false.
#   Valid values are `true`, `false`, `listed_permissions`.
#
# === Properties
#
# [*inherit_parent_permissions*]
#   Inherit Parent Permissions specifies whether to inherit
#   permissions from parent ACLs or not. The default is `true`.
#   Valid values are `true`, `false`.
#   Requires features can_inherit_parent_permissions.
#
# [*owner*]
#   The owner identity is also known as a trustee or principal
#   that is said to own the particular acl/security descriptor. This
#   can be in the form of: 1. User - e.g. `'Bob'` or `'TheNet\Bob'`,
#   2. Group e.g. `'Administrators'` or `'BUILTIN\Administrators'`, 3.
#   SID (Security ID) e.g. `'S-1-5-18'`. Defaults to not specified on
#   Windows. This allows owner to stay set to whatever it is currently
#   set to (owner can vary depending on the original CREATOR OWNER).
#   The trustee must exist on the system and will auto-require on user
#   and group resources.
#
# [*group*]
#   The group identity is also known as a trustee or principal
#   that is said to have access to the particular acl/security descriptor.
#   This can be in the form of: 1. User - e.g. `'Bob'` or `'TheNet\Bob'`,
#   2. Group e.g. `'Administrators'` or `'BUILTIN\Administrators'`, 3.
#   SID (Security ID) e.g. `'S-1-5-18'`. Defaults to not specified on
#   Windows. This allows group to stay set to whatever it is currently
#   set to (group can vary depending on the original CREATOR GROUP).
#   The trustee must exist on the system and will auto-require on user
#   and group resources.
#
# [*permissions*]
#   Permissions is an array containing Access Control Entries
#   (ACEs). Certain Operating Systems require these ACEs to be in
#   explicit order (Windows). Every element in the array is a hash
#   that will at the very least need `identity` and `rights` e.g
#   `{ identity => 'Administrators', rights => ['full'] }` and at the
#   very most can include `type`, `child_types`, `affects`, and
#   `mask` (mask should only be specified with `rights => ['mask_specific']`)
#   e.g. `{ identity => 'Administrators', rights => ['full'],
#   type=> 'allow', child_types => 'all', affects => 'all' }`.
#
#   `identity` is a group, user or ID (SID on Windows). The identity must
#   exist on the system and will auto-require on user and group resources.
#
#   `rights` is an array that contains 'full', 'modify', 'mask_specific'
#   or some combination of 'write', 'read', and 'execute'. If you specify
#   'mask_specific' you must also specify `mask` with an integer (passed
#   as a string) that represents the permissions mask.
#
#   `type` is represented as 'allow' (default) or 'deny'.
#
#   `child_types` determines how an ACE is inherited downstream from the target.
#   Valid values are `'all'` (default), `'objects'`, `'containers'` or `'none'`.
#
#   `affects` determines how the downstream inheritance is propagated. Valid
#   values are `'all'` (default), `'self_only'`, `'children_only'`,
#   `'self_and_direct_children_only'` or `'direct_children_only'`.
#
#   Each permission (ACE) is determined to be unique based on `identity`,
#   `type`, `child_types`, and `affects`. While you can technically create more
#   than one ACE that differs from other ACEs only in rights, acl module
#   is not able to tell the difference between those so it will appear that
#   the resource is out of sync every run when it is not.
#
#   While you will see `is_inherited => 'true'` when running puppet resource
#   acl path, puppet will not be able to manage the inherited permissions so
#   those will need to be removed if using that to build a manifest.
#
# === Examples
#
# At a minimum, you need to provide the target and at least
# one permission (access control entry or ACE). It will default
# the other settings to sensible defaults.
# Minimally expressed sample usage:
#   acl { 'c:/tempperms':
#     permissions => [
#      { identity => 'Administrator', rights => ['full'] },
#      { identity => 'Users', rights => ['read','execute'] }
#    ],
#   }
# If you want you can provide a fully expressed ACL. The
# fully expressed acl in the sample below produces the same
# settings as the minimal sample above.
#
# Fully expressed sample usage:
#
#   acl { 'c:/tempperms':
#     target      => 'c:/tempperms',
#     target_type => 'file',
#     purge       => 'false',
#     permissions => [
#      { identity => 'Administrator', rights => ['full'], type=> 'allow',
# child_types => 'all', affects => 'all' },
#      { identity => 'Users', rights => ['read','execute'], type=> 'allow',
# child_types => 'all', affects => 'all' }
#     ],
#     owner       => 'Administrators', #Creator_Owner specific, doesn't manage
# unless specified
#     group       => 'Users', #Creator_Group specific, doesn't manage unless
# specified
#     inherit_parent_permissions => 'true',
#   }
#
# You can manage the same target across multiple acl
# resources with some caveats. The title of the resource
# needs to be unique. It is suggested that you only do
# this when you would need to (can get confusing). You should
# not set purge => 'true' on any of the resources that apply
# to the same target or you will see thrashing in reports as
# the permissions will be added and removed every catalog
# application. Use this feature with care.
# Manage same ACL resource multiple acls sample usage:
#   acl { 'c:/tempperms':
#     permissions => [
#      { identity => 'Administrator', rights => ['full'] }
#    ],
#   }
#
#   acl { 'tempperms_Users':
#     target      => 'c:/tempperms',
#     permissions => [
#      { identity => 'Users', rights => ['read','execute'] }
#    ],
#   }
#
# Removing upstream inheritance with purge sample usage:
#   acl { 'c:/tempperms':
#     purge       => 'true',
#     permissions => [
#      { identity => 'Administrators', rights => ['full'] },
#      { identity => 'Users', rights => ['full'] }
#     ],
#     inherit_parent_permissions => 'false',
#   }
#
# === Authors
#
# Josh Cooper <josh@puppetlabs.com>
# Rob Reynolds <rob@puppetlabs.com>
# Ethan Brown <ethan@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013-Present Puppet Labs, unless otherwise noted.
#
class acl {
}
