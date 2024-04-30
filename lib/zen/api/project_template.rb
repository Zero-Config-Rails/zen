require "httparty"

module Zen
  module Api
    class ProjectTemplate
      def fetch_details(id)
        HTTParty.get("#{api_url}/#{id}")
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
