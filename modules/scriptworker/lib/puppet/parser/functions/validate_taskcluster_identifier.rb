module Puppet::Parser::Functions
  newfunction(:validate_taskcluster_identifier) do |args|
    # TaskCluster has a 22-character-limit on some fields. See
    # https://github.com/taskcluster/taskcluster-queue/blob/d45c29675461ceff3a38c6881edfe700855f4517/schemas/constants.yml#L23
    identifier_value = args[0]
    raise ArgumentError, "TaskCluster identifier must be a String" unless identifier_value.kind_of? String
    raise ArgumentError, "TaskCluster identifier must not be empty" unless !identifier_value.empty?
    raise ArgumentError, "Invalid TaskCluster identifier: '#{identifier_value}' contains more than 22 characters." unless identifier_value.length <= 22
  end
end
