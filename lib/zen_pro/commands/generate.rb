require_relative "create"
require_relative "configure"
require_relative "../api/project_template"

module ZenPro
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

        ZenPro::Commands::Create.run(all_options)
        # TODO: call class/method to save progress since rails app is now generated
        ZenPro::Commands::Configure.run(all_options)
        # TODO: API call to mark project as configured and store all configurations
        instance.setup_complete_message(app_name)
      rescue StandardError => e
        prompt = TTY::Prompt.new

        prompt.error "\nOops, Zen encountered an error!"

        prompt.error "\n#{e.message}"
      end

      def welcome_message
        prompt.say <<~BANNER
          We will ask you few questions while all other options will automatically be added as per application configurations in the Web App.
        BANNER
      end

      def ask_app_name
        name =
          prompt.ask "\nWhat would you like to name your app? e.g. zero_config_rails or zero-config-rails"

        name.chomp
      end

      def fetch_project_template_configurations(id)
        prompt.say "\nFetching your project's configurations from the server...\n\n"

        ZenPro::Api::ProjectTemplate.new.fetch_details(id)
      end

      def setup_complete_message(app_name)
        prompt.say "\n🎉🎉🎉"
        prompt.ok "Congratulations! Your app is fully configured.\n"

        prompt.say <<~BANNER
          1. Run the rails server with `cd #{app_name} && rails s`
          2. You can access the app at http://localhost:3000
        BANNER
      end

      private

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
      end
    end
  end
end
