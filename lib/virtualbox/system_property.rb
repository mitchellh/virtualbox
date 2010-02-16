module VirtualBox
  class SystemProperty < Hash
    class <<self
      def all
        raw = Command.vboxmanage("list", "systemproperties")
        parse_raw(raw)
      end

      def parse_raw(data)
        result = new
        data.split("\n").each do |line|
          next unless line =~ /^(.+?):\s+(.+?)$/
          value = $2.to_s
          key = $1.to_s.downcase.gsub(/\s/, "_")
          result[key.to_sym] = value
        end

        result
      end
    end
  end
end