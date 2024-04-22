require "json"
require "tty-prompt"
require "tty-spinner"

module Zen
  module Commands
    class Create
      def self.run(project_template_id, app_name, _options)
        new(project_template_id, app_name).execute
      end

      def initialize(project_template_id, app_name)
        @project_template_id = project_template_id
        @app_name = app_name
      end

      def execute
        fetch_project_template_configurations
        generate_rails_app
        run_bin_setup
      end

      private

      attr_reader :project_template_id,
                  :app_name,
                  :optional_application_configurations,
                  :rails_generator_options,
                  :after_rails_generate_commands

      def fetch_project_template_configurations
        prompt.say "Fetching your project's configurations from the server ..."
        spinner.start

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
          after_rails_generate_commands: ["bundle exec rails g boring:rspec:install"]
        }
        configurations_in_json = JSON.dump(configurations_hash)
        configurations = JSON.parse(configurations_in_json)

        @optional_application_configurations =
          configurations["application_configurations"]
        @rails_generator_options = configurations["rails_generator_options"]
        @after_rails_generate_commands =
          configurations["after_rails_generate_commands"]

        spinner.pause
      end

      # TODO: CLI is not exiting when generators are not found, find some way to raise error and exit in this case. It's rare for this to happen but we need to at least make sure app raises error for unknown situations and exit instead of continuing to another step
      def generate_rails_app
        rails_generate_command =
          "rails new #{app_name} #{rails_generator_options} --skip"

        if after_rails_generate_commands.length.positive?
          commands_to_display =
            [rails_generate_command, *after_rails_generate_commands, "bin/setup"].map
              .with_index { |command, index| "#{index + 1}. #{command}" }
              .join("\n")

          prompt.say <<~BANNER
          \nWe will generate a new Rails app at ./#{app_name} and execute following commands:
    
          #{commands_to_display}
          BANNER
        else
          prompt.say <<~BANNER
          \nWe will generate a new Rails app at ./#{app_name} with the command:

            #{rails_generate_command}
          BANNER
        end

        # continue_if? "Continue"

        system! rails_generate_command

        install_boring_generators_gem

        Dir.chdir(app_name) do
          after_rails_generate_commands.map do |command|
            system! "bundle exec #{command}"
          end
        end
      rescue StandardError
        system! "rm -rf #{app_name}"
      end

      def run_bin_setup
        Dir.chdir(app_name) { system! "bin/setup" }
      end

      def install_boring_generators_gem
        prompt.say <<~BANNER
          \nZen requires boring_generators gem to install and configure gems you have chosen, adding it to your project's Gemfile so generators for gems are available inside your app during configuration.
          (We will remove it automatically once the app is fully configured!)
        BANNER

        Dir.chdir(app_name) { system! "bundle add boring_generators" }
      end

      # TODO: It will be better to register everything below this as Thor commands so they can be used throughout the app
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

        prompt.error "Canceled"
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
