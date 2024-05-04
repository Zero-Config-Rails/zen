require "json"
require "tty-prompt"
require "tty-spinner"

module Zen
  module Commands
    class Create
      def self.run(options)
        new(options).execute
      end

      def initialize(options)
        @app_name = options[:app_name]
        @project_configurations = options[:project_configurations]
      end

      def execute
        generate_rails_app
        run_bin_setup
      rescue StandardError => e
        system! "rm -rf #{app_name}"

        raise e
      end

      private

      attr_reader :app_name, :project_configurations

      def generate_rails_app
        rails_generate_command =
          "rails new #{app_name} #{rails_generator_options}"
        commands_to_display = [
          rails_generate_command,
          "bundle add boring_generators --group=development",
          "bin/setup"
        ]

        if after_rails_generate_commands.length.positive?
          commands_to_display.insert(2, after_rails_generate_commands)
        end

        commands_to_display =
          commands_to_display
            .map
            .with_index { |command, index| "#{index + 1}. #{command}" }
            .join("\n")

        prompt.say <<~BANNER
          \nWe will generate a new Rails app at ./#{app_name} and execute following commands:

          #{commands_to_display}
        BANNER

        continue_if? "\nContinue?"

        system! rails_generate_command

        install_boring_generators_gem

        Dir.chdir(app_name) do
          after_rails_generate_commands.each do |command|
            system! "bundle exec #{command}"
          end
        end
      end

      def run_bin_setup
        Dir.chdir(app_name) { system! "bin/setup" }
      end

      def rails_generator_options
        project_configurations["rails_generator_options"]
      end

      def after_rails_generate_commands
        project_configurations["after_rails_generate_commands"]
      end

      def install_boring_generators_gem
        message = <<~BANNER
          \nZen requires boring_generators gem to install and configure gems you have chosen, adding it to your project's Gemfile so generators for gems are available inside your app during configuration.\n
        BANNER

        prompt.say message, color: :blue

        Dir.chdir(app_name) do
          system! "bundle add boring_generators --group=development"
        end
      end

      # TODO: Register everything below this as Thor commands so they can be used throughout the app
      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
      end

      # TODO: only load spinners if --silent option is enabled else output will be shown in shell so this is not required
      def spinner
        return @spinner if defined?(@spinner)

        TTY::Spinner.new(format: :dots)
      end

      def continue_if?(question)
        return if prompt.yes?(question)

        prompt.error "Cancelled"
        exit
      end

      def system!(*args)
        system(*args)
      rescue StandardError
        prompt.error "\n== Command #{args} failed =="
        exit
      end
    end
  end
end
