require "thor"

require_relative "create"
require_relative "configure"
require_relative "../api/project_template"

module Zen
  module Commands
    class Generate
      def self.run(project_template_id, options)
        instance = new

        instance.welcome_message
        app_name = instance.ask_app_name
        project_configurations =
          instance.fetch_project_template_configurations(project_template_id)
        all_options = {
          project_template_id: project_template_id,
          app_name: app_name,
          project_configurations: project_configurations,
          **options
        }

        Zen::Commands::Create.run(all_options)
        # TODO: call class/method to save progress since rails app is now generated
        Zen::Commands::Configure.run(all_options)
        # TODO: API call to mark project as configured and also to store all configurations
        instance.setup_complete_message
      end

      def welcome_message
        prompt.say <<~BANNER
            Welcome to Zero Config Rails!

            We will ask you a few questions while all other options will automatically be added as per application configurations in the Web App.
          BANNER
      end

      def ask_app_name
        name =
          prompt.ask "\nWhat would you like to name your app? e.g. zero_config_rails or zero-config-rails"

        name.chomp
      end

      def fetch_project_template_configurations(id)
        prompt.say "Fetching your project's configurations from the server ..."
        # spinner.start

        configurations = Zen::Api::ProjectTemplate.new.fetch_details(id)

        # spinner.pause

        configurations
      end

      def setup_complete_message
        prompt.success "Your app has been fully configured!"
      end

      private

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
      end
    end
  end
end
