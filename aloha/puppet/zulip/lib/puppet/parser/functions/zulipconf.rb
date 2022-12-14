module Puppet::Parser::Functions
  newfunction(:alohaconf, :type => :rvalue, :arity => -2) do |args|
    default = args.pop
    joined = args.join(" ")
    aloha_conf_path = lookupvar("aloha_conf_path")
    output = `/usr/bin/crudini --get #{aloha_conf_path} #{joined} 2>&1`; result = $?.success?
    if result
      if [true, false].include? default
        # If the default is a bool, coerce into a bool
        ['1','y','t','true','yes','enable','enabled'].include? output.strip.downcase
      else
        output.strip
      end
    else
      default
    end
  end

  newfunction(:alohaconf_keys, :type => :rvalue, :arity => 1) do |args|
    aloha_conf_path = lookupvar("aloha_conf_path")
    output = `/usr/bin/crudini --get #{aloha_conf_path} #{args[0]} 2>&1`; result = $?.success?
    if result
      return output.lines.map { |l| l.strip }
    else
      return []
    end
  end

  newfunction(:alohaconf_nagios_hosts, :type => :rvalue, :arity => 0) do |args|
    section = "nagios"
    prefix = "hosts_"
    ignore_key = "hosts_fullstack"
    aloha_conf_path = lookupvar("aloha_conf_path")
    keys = `/usr/bin/crudini --get #{aloha_conf_path} #{section} 2>&1`; result = $?.success?
    if result
      keys = keys.lines.map { |l| l.strip }
      filtered_keys = keys.select { |l| l.start_with?(prefix) }.reject { |k| k == ignore_key }
      all_values = []
      filtered_keys.each do |key|
        values = `/usr/bin/crudini --get #{aloha_conf_path} #{section} #{key} 2>&1`; result = $?.success?
        if result
          all_values += values.strip.split(/,\s*/)
        end
      end
      return all_values
    else
      return []
    end
  end
end
