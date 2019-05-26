#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
module Core
  class Logger
    include Singleton
    
    # Constructor
    def initialize
      @logs = BeEF::Core::Models::Log
      @config = BeEF::Core::Configuration.instance

      # if notifications are enabled create a new instance
      @notifications = BeEF::Extension::Notifications::Notifications unless @config.get('beef.extension.notifications.enable') == false
    end

    #
    # Registers a new event in the logs
    # @param [String] from The origin of the event (i.e. Authentication, Hooked Browser)
    # @param [String] event The event description
    # @param [Integer] hb The id of the hooked browser affected (default = 0 if no HB)
    #
    # @return [Boolean] True if the register was successful
    #
    def register(from, event, hb = 0)
      # type conversion to enforce standards
      hb = hb.to_i

      # get time now
      time_now = Time.now
      
      # arguments type checking
      raise TypeError, '"from" needs to be a string' unless from.string?
      raise TypeError, '"event" needs to be a string' unless event.string?
      raise TypeError, '"Hooked Browser ID" needs to be an integer' unless hb.integer?

      # logging the new event into the database
      @logs.new(:type => from.to_s, :event => event.to_s, :date => time_now, :hooked_browser_id => hb).save
      print_debug "Event: #{event}"
      # if notifications are enabled send the info there too
      if @notifications
        @notifications.new(from, event, time_now, hb)
      end
      
      true
    end

    private
    @logs
  end
end
end
