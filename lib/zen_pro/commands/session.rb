require "netrc"

module ZenPro
  module Commands
    class Session
      def initialize(project_template_id)
        @project_template_id = project_template_id
      end

      def login
        return api_token if logged_in?

        api_token_to_save =
          prompt.ask "Enter your API token for #{project_template_id}:"

        netrc = Netrc.read

        netrc[
          "zeroconfigrails.com/#{project_template_id}"
        ] = project_template_id,
        api_token_to_save
        netrc.save

        prompt.ok "You are now logged in to the session for #{project_template_id}!\n"

        api_token_to_save
      rescue StandardError => e
        prompt.error "\nOops, Zen encountered an error while logging you in!"

        prompt.say "\n#{e.message}"

        raise e
      end

      def logout
        netrc = Netrc.read

        netrc.delete("zeroconfigrails.com/#{project_template_id}")
        netrc.save

        prompt.ok "You are now logged out of the session for #{project_template_id}"
      end

      private

      attr_reader :project_template_id

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
      end

      def logged_in?
        !api_token.nil?
      end

      def api_token
        netrc = Netrc.read

        _project_template_id, api_token =
          netrc["zeroconfigrails.com/#{project_template_id}"]

        api_token
      end
    end
  end
end
