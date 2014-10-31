module Fetch
  # A request to be completed with Typhoeus.
  class Request
    # Initializes the request and sets properties to the values defined in
    # +options+.
    #
    #   request = Fetch::Request.new("http://www.google.com", timeout: 5)
    #   request.url     # => "http://www.google.com"
    #   request.timeout # => 5
    #
    #   request = Fetch::Request.new(timeout: 5)
    #   request.url     # => nil
    #   request.timeout # => 5
    def initialize(*args)
      options = args.pop if args.last.is_a?(Hash)

      if args.any?
        self.url = args.first
      end

      if options
        options.each { |key, value| send("#{key}=", value) }
      end
    end

    # The URL to be requested.
    attr_accessor :url

    # Whether to follow redirects.
    # Default: +true+
    def follow_redirects
      return @follow_redirects if defined?(@follow_redirects)
      @follow_redirects = true
    end

    attr_writer :follow_redirects

    # The timeout for the request.
    # Default: Taken from +Fetch.config.timeout+
    def timeout
      return @timeout if defined?(@timeout)
      Fetch.config.timeout
    end

    attr_writer :timeout

    # The headers to be sent with the request.
    def headers
      @headers ||= {
        "User-Agent" => Fetch.config.user_agent
      }
    end

    attr_writer :headers

    # The user agent being sent with the request.
    def user_agent
      headers["User-Agent"]
    end

    def user_agent=(value)
      headers.merge! "User-Agent" => value
    end

    # Sets the callback to be run when the request completes
    def process(&block)
      if block_given?
        @process_block = block
      else
        @process_block ||= Proc.new
      end
    end
  end
end