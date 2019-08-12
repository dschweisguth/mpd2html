module MPD2HTML
  class Logger
    def self.verbose=(verbose)
      @verbose = verbose
    end

    def self.error(message)
      Kernel.warn message
    end

    def self.warn(message)
      if @verbose
        Kernel.warn message
      end
    end

  end
end
