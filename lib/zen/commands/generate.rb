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

        Zen::Commands::Create.run(project_template_id, app_name, options)
        Zen::Commands::Configure.run(project_template_id, app_name, options)
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

      private

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
      end
    end
  end
end
