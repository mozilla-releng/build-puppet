# A type to modify the Windows PATH variable in an idempotent manner.
Puppet::Type.newtype(:windows_path) do
    @doc = "Manages the Windows environment variable PATH"

    ensurable

    newparam(:directory, :namevar => true) do
       desc "The path entry to be managed."
    end

    newparam(:target) do
       desc "If the user or sytem path is to be modified."

       newvalues(:system, :user)
       defaultto(:system)

       # TODO if :user, maybe provide another param controlling *which* user's path
       # is to be modified (if it is possible to write to a different users's path
       # in the registry).
    end
end
