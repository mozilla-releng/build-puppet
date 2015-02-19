# Constants for broadcasting the PATH change.
# For details on Windows API method SendMessageTimeout see
# http://msdn.microsoft.com/en-us/library/windows/desktop/ms644952%28v=vs.85%29.aspx
DLL = 'user32'
API_METHOD = 'SendMessageTimeout'
API_METHOD_PARAMETER_TYPES = 'LLLPLLP'
API_METHOD_RETURN_TYPE = 'L'
# Receiver of the message, 0xffff means broadcast (all top level windows in the system)
HWND_BROADCAST = 0xffff
# Message to send
WM_SETTINGCHANGE = 0x001A
# This means: The function returns without waiting for the time-out
# period to elapse if the receiving thread appears to not respond or "hangs." 
SMTO_ABORTIFHUNG = 2
# wait 5 seconds maximum for the broadcast to be successful
BROADCAST_TIMEOUT = 5000


Puppet::Type.type(:windows_path).provide(:windows_path) do
    desc "Manage the Windows environment variable PATH"

    confine :osfamily => :windows
    defaultfor :osfamily => :windows

    def create
       debug "appending #{@directory} to PATH"
       @path_entries.push @directory
       new_path = @path_entries.join(@separator)
       write_path new_path
       do_broadcast
    end

    def destroy
       debug "removing #{@directory} from PATH"
       @path_entries.delete_if { |s| s.casecmp(@directory) == 0}
       new_path = @path_entries.join(@separator)
       write_path new_path
       do_broadcast
    end

    def exists?
        @directory = resource[:directory]
        debug "checking existence of #{@directory} in PATH"
        fetch_target
        complete_path = read_path
        debug "current PATH: #{complete_path}"
        @separator = ('windows' == Facter.value('osfamily')) ? ';' : ':'
        # debug "separator:  #{@separator}"
        @path_entries = complete_path.split @separator 
 
        # TODO We probably should normalize the path entry separator ("/" or "\")
        # to "\", both in the complete_path/@path_entries and in @directory.
        # This would allow to use pathes with / and \ in the resource declaration.

        path_entry_already_present = @path_entries.any?{ |s| s.casecmp(@directory) == 0 }
        debug "PATH entry already present: #{path_entry_already_present}"
        return path_entry_already_present
    end
    

    private

    def require_windows
      # win32/registry and Win32API are part of the stdlib on Windows, no extra gems
      # are required.
      require 'win32/registry.rb'
      require 'Win32API'
    end

    def fetch_target
        require_windows

        @target = resource[:target] 
        debug "Target: #{@target}"

        if :user == @target then
            @registry_location = Win32::Registry::HKEY_CURRENT_USER
            @registry_path = 'Environment'
        else
            # Note: To write to the system path, puppet needs certain
            # permissions. When using the puppet shell that comes with the
            # Windows installer, the puppet shell should be run as administrator,
            # for example. 
            @registry_location = Win32::Registry::HKEY_LOCAL_MACHINE
            @registry_path = 'System\CurrentControlSet\Control\Session Manager\Environment'
        end
        debug "registry location: #{@registry_location}"
        debug "registry path: #{@registry_path}"
    end

    def read_path
        require_windows

        debug "Reading PATH from registry"
        path = nil
        begin
            @registry_location.open(@registry_path, Win32::Registry::KEY_READ) do |registry|
                path = registry['PATH']
            end
        rescue Win32::Registry::Error => e
            if e.message == "The system cannot find the file specified." then
                # In case of user path, it's perfectly possible that the user just
                # has no path configured.
                warning "It seems there was no PATH variable in the registry for target #{@target} at #{@registry_location}. If needed, it will be created."
                path = ""
            else
                raise e
            end
        end
        debug "PATH read from registry: #{path}"
        path
    end

    def write_path(path)
        require_windows

        notice "Writing new PATH: #{path}"

        begin
            @registry_location.open(@registry_path, Win32::Registry::KEY_WRITE) do |registry|
                registry['PATH'] = path 
            end
        # TODO only rescue the specific exception that is thrown when puppet does
        # have the required permissions to write to that registry entry. Then
        # convert it to a less cryptic error that indicates the problem (like: not
        # enough permissions to write to the system path).
        rescue Exception => e
            warning "Writing to the registry failed. That might be a permission problem. Does puppet have administrator privileges? Caught exception was: #{e.to_s} -- #{e.class} -- #{e.message}"
            raise e
        end
        # Also see
        # http://stackoverflow.com/questions/190168/persisting-an-environment-variable-through-ruby
        # and
        # http://stackoverflow.com/questions/912982/use-ruby-to-permanently-ie-in-the-registry-set-environment-variables
        debug "New PATH has been written to registry"
    end

    # Make new PATH visible without logging off and on again.
    def do_broadcast
        require_windows

        sendMessageMethod = Win32API.new(DLL, API_METHOD, API_METHOD_PARAMETER_TYPES, API_METHOD_RETURN_TYPE)

        # For details on Windows API method SendMessageTimeout see
        # http://msdn.microsoft.com/en-us/library/windows/desktop/ms644952%28v=vs.85%29.aspx

        sendMessageMethod.call(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment', SMTO_ABORTIFHUNG, BROADCAST_TIMEOUT, 0)
    end    
end
