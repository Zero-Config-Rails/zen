require "tty-prompt"

module Zen
  module Commands
    class Configure
      def self.run(options)
        new(options).execute
      end

      def initialize(options)
        @app_name = options[:app_name]
        @gems_configuration_commands =
          options[:project_configurations]["gems_configuration_commands"]
      end

      def execute
        commands_to_display =
          gems_configuration_commands
            .each
            .with_index { |command, index| "#{index + 1}. #{command}" }
            .join("\n")

        prompt.say <<~BANNER
          \nRails app is now ready with initial configurations. Next, we will move on to configuring gems you have chosen by executing following commands:

          #{commands_to_display}
          BANNER

        continue_if? "\nContinue?"

        Dir.chdir(app_name) do
          gems_configuration_commands.each do |command|
            system! "bundle exec #{command}"
            # TODO: save progress in some file inside the user's generated app so we can continue from same point if user leaves in the middle or if app exits due to some error. Also find some way to update configurations in async without stopping any gem configuration operations (not important till MVP)
          end
        end

        # TODO: generators for github action CI requires repository name, we need to install them if user has enabled the option to install CI in the app. We can configure them with app_name for now and notify users to change it if required
      ensure
        # TODO: move this code to be around after configurations message in future
        Dir.chdir(app_name) do
          prompt.say "\nRemoving boring_generators gem since it's no longer required"

          system! "bundle remove boring_generators"
        end
      end

      private

      attr_reader :app_name, :gems_configuration_commands

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
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
