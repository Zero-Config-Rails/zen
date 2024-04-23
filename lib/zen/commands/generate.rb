require "thor"

require_relative "create"
require_relative "configure"

module Zen
  module Commands
    class Generate
      def self.run(project_template_id, options)
        instance = new

        instance.welcome_message
        app_name = instance.ask_app_name
        project_configurations = instance.fetch_project_template_configurations
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
        setup_complete_message
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

      def fetch_project_template_configurations
        prompt.say "Fetching your project's configurations from the server ..."
        # spinner.start

        configurations_hash = {
          id: "GDxyJ",
          name: "Default",
          application_configurations: [
            {
              configuration_key: "port-number",
              default_value: "3000",
              is_rails_generator_option: false,
              value: "3000"
            },
            {
              configuration_key: "test-framework",
              default_value: "minitest",
              is_rails_generator_option: false,
              value: "rspec"
            }
          ],
          rails_generator_options:
            "--database=postgresql --css=tailwind --skip-test",
          after_rails_generate_commands: [
            "rails g boring:rspec:install"
          ],
          gems_configuration_commands: [
            "rails g boring:devise:install --model_name=User",
            "rails g boring:pundit:install",
            "rails g boring:letter_opener:install",
            "rails g boring:bullet:install",
            "rails g boring:webmock:install --app_test_framework=rspec"
          ]
        }
        configurations_in_json = JSON.dump(configurations_hash)
        configurations = JSON.parse(configurations_in_json)

        # spinner.pause

        configurations
      end

      private

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
      end
    end
  end
end
