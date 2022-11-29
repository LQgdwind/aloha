module Puppet::Parser::Functions
  newfunction(:alohasecret, :type => :rvalue) do |args|
    default = args.pop
    joined = args.join(" ")
    output = `/usr/bin/crudini --get /etc/aloha/aloha-secrets.conf #{joined} 2>&1`; result = $?.success?
    if result
      output.strip()
    else
      default
    end
  end
end
