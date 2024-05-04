require "rest-client"
require "debug"

module Zen
  module Api
    class ProjectTemplate
      def fetch_details(id)
        response = RestClient.get("#{api_url}/#{id}")

        JSON.parse(response)
      rescue RestClient::ExceptionWithResponse => e
        raise e.response
      end

      private

      def api_url
        base_url =
          if ENV["DEVELOPMENT"]
            "http://localhost:3000"
          else
            "https://zeroconfigrails.com"
          end

        "#{base_url}/api/v1/project_templates"
      end
    end
  end
end
