require "rest-client"
require "tty-box"

module ZenPro
  module Api
    class ProjectTemplate
      def fetch_details(id)
        response = RestClient.get("#{api_url}/#{id}", authorization_header(id))

        JSON.parse(response)
      rescue RestClient::ExceptionWithResponse => e
        prompt = TTY::Prompt.new

        prompt.say <<~RE_LOGIN_MESSAGE if e.response.code == 401
          You can logout and login again if the API Token had some typo/mistake:

          1. Logout first: zen_pro logout #{id}
          2. Login back and add correct API Token: zen_pro g #{id}
        RE_LOGIN_MESSAGE

        json_response = string_to_json(e.response)

        if e.response.code == 403 && json_response &&
             json_response["is_subscription_inactive"]
          print TTY::Box.error <<~SUBSCRIPTION_EXPIRED_INSTRUCTIONS
            It looks like your subscription has either expired or you are on Free plan.

            You can upgrade your account from the following URL:

            https://zeroconfigrails.com/account/teams/#{json_response["team_id"]}/billing/subscriptions
          SUBSCRIPTION_EXPIRED_INSTRUCTIONS
        end

        raise(e)
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

      def authorization_header(id)
        netrc = Netrc.read

        _project_template_id, api_token = netrc["zeroconfigrails.com/#{id}"]

        { Authorization: "Bearer #{api_token}" }
      end

      def string_to_json(string)
        JSON.parse(string)
      rescue StandardError
        false
      end
    end
  end
end
