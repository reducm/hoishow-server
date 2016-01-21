require "socket"
require "uri"
require "connection_pool"
require "pry"

SSDB_DEFAULT_URL = "ssdb://127.0.0.1:6380/"

class SSDB
  Error           = Class.new(RuntimeError)
  ConnectionError = Class.new(Error)
  TimeoutError    = Class.new(Error)
  CommandError    = Class.new(Error)
  FutureNotReady  = Class.new(Error)
end

class SSDB
  @@pool = nil

  def self.init(opts={})
    size = opts.fetch :size, 5
    timeout = opts.fetch :timeout, 5

    @@pool = ConnectionPool.new(size: size, timeout: timeout) do
      SSDB::Client.new(opts).connect
    end
  end

  def self.with(&block)
    if @@pool.nil?
      raise SSDB::Error, "need invoke SSDB.init before call SSDB.with"
    end
    @@pool.with &block
  end

  class Client
    NL = "\n".freeze
    OK = "ok".freeze
    NOT_FOUND = "not_found".freeze

    attr_reader :url, :timeout
    attr_accessor :reconnect

    def initialize(opts = {})
      @timeout   = opts[:timeout] || 10.0
      @sock      = nil
      @url       = parse_url(opts[:url] || ENV["SSDB_URL"] || SSDB_DEFAULT_URL)
      @reconnect = opts[:reconnect] != false
    end

    def parse_url(url)
      url = URI(url) if url.is_a?(String)

      # Validate URL
      unless url.host
        raise ArgumentError, "Invalid :url option, unable to determine 'host'."
      end

      url
    end

    def port
      @port ||= url.port || 6380
    end

    def sock_timeout
      @sock_timeout ||= begin
        secs  = Integer(timeout)
        usecs = Integer((timeout - secs) * 1_000_000)
        [secs, usecs].pack("l_2")
      end
    end

    def connect
      addr = Socket.getaddrinfo(url.host, nil)
      @sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)
      @sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, sock_timeout
      @sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, sock_timeout
      @sock.connect(Socket.pack_sockaddr_in(port, addr[0][3]))
      self
    end

    # @return [Boolean] true if connected
    def connected?
      !!@sock
    end

    # Disconnects the client
    def disconnect
        @sock.close if connected?
      rescue
      ensure
        @sock = nil
    end

    # Safely perform IO operation
    def io(op, *args)
      @sock.__send__(op, *args)
    rescue Errno::EAGAIN
      raise SSDB::TimeoutError, "Connection timed out"
    rescue Errno::ECONNRESET, Errno::EPIPE, Errno::ECONNABORTED, Errno::EBADF, Errno::EINVAL => e
      raise SSDB::ConnectionError, "Connection lost (%s)" % [e.class.name.split("::").last]
    end

    def exec(cmds)
      data = ""
      cmds.each do |cmd|
        cmd = cmd.to_s
        data << cmd.bytesize.to_s << NL << cmd << NL
      end
      data << NL

      send_data data
      recv_data
    end

    def hgetall(table, result_type = :dict, &decode)
      result = exec ["hgetall", table]
      ok = _ok? result

      case result_type
        when :list then
          return _list(result, &decode)
        else
          return _dict(result, &decode)
      end
    end

    def hget(table, key, &decode)
      result = exec ["hget", table, key]
      if _ok? result
        decode ? decode.call(result[1]) : result[1]
      else
        nil
      end
    end

    def hset(table, key, data, &encode)
      data = encode.call(data) if encode
      result = exec ["hset", table, key, data]
      _ok? result
    end

    def get(key, &decode)
      result = exec ["get", key]
      if _ok? result
        decode ? decode.call(result[1]) : result[1]
      else
        nil
      end
    end

    def set(key, data, ttl=0,  &encode)
      data = encode.call(data) if encode

      if ttl > 0
        exec ["setx", key, data, ttl]
      else
        exec ["set", key, data]
      end
    end

    def del(key)
      exec ["del", key]
    end

    def _ok?(items)
      items[0] == "ok"
    end

    def _dict(items, &decode)
      result = Hash.new
      if _ok?(items)
        items[1..-1].each_slice(2) do |field, value|
          result[field] = decode ? decode.call(value) : value
        end
      end
      result
    end

    def _list(items, &decode)
      _dict(items, &decode).values
    end

    def send_data(data)
      io(:write, data)
    end

    def recv_data
      state = :size
      data = []
      size = 0
      prefix = ""

      while true
        case state
        when :size # read size block
          size = (prefix + io(:gets)).chomp.to_i
          state = :data
        when :data # read data block
          s = io(:read, size + 2)
          prefix = s[-1]
          if prefix == NL # end
            prefix = ""
            data.push s[0, size]
            return data
          else # data
            data.push s[0, size]
            state = :size
          end
        end
      end
    end

  end
end