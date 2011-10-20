module Semrush
  module Exception
    class Base < ::Exception
      def initialize query = nil, message = ""
        message = "[query=#{query.inspect}] #{message}" if !query.nil?
        super(message)
      end
    end
  end
end
Dir[File.expand_path('../exception/', __FILE__)+'/*.rb'].each {|file| require(file) }