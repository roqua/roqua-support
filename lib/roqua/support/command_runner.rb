require 'pty'

module CommandRunner
  def self.run_command_and_print(cmd, output)
    output.puts "[1mExecuting #{cmd}[0m\n\n"

    PTY.spawn(cmd) do |read_stream, write_stream, pid|
      begin
        while chars = read_stream.read(1)
          output.print chars
        end
      rescue Errno::EIO
      end
      Process.wait(pid)
    end
    output.puts "\n\n\n"

    if $?
      exit 1 if $?.exitstatus > 0
    else
      raise "Huh?! We didn't get an exit status from that last one: #{cmd}"
    end
  end
end