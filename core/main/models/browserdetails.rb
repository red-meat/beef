#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the details of browsers.
  #
  # For example, the type and version of browser the hooked browsers are using.
  #
  class BrowserDetails
  
    include DataMapper::Resource
    
    storage_names[:default] = 'core_browserdetails'
    property :session_id, String, :length => 255, :key => true
    property :detail_key, String, :length => 255, :lazy => false, :key => true
    property :detail_value, Text, :lazy => false  
     
    #
    # Returns the requested value from the data store
    #
    def self.get(session_id, key) 
      browserdetail = first(:session_id => session_id, :detail_key => key)
      
      return nil if browserdetail.nil?
      return nil if browserdetail.detail_value.nil?
      return browserdetail.detail_value
    end
  
    #
    # Stores or updates an existing key->value pair in the data store
    #
    def self.set(session_id, detail_key, detail_value) 
      browserdetails = BeEF::Core::Models::BrowserDetails.all(
        :session_id => session_id,
        :detail_key => detail_key )
      if browserdetails.nil? || browserdetails.empty?
        # store the new browser details key/value
        browserdetails = BeEF::Core::Models::BrowserDetails.new(
              :session_id   => session_id,
              :detail_key   => detail_key,
              :detail_value => detail_value || '')
        result = browserdetails.save
      else
        # update the browser details key/value
        result = browserdetails.update(:detail_value => detail_value || '')
        print_debug "Browser has updated '#{detail_key}' to '#{detail_value}'"
      end

      # if the attempt to save the browser details fails return a bad request
      if result.nil?
        print_error  "Failed to save browser details: #{detail_key}=#{detail_value}"
      end
    
      browserdetails
    end
  end
end
end
end
