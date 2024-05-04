require "tty-prompt"

module ZenPro
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

      # TODO: CLI doesn't exit when generators are not found, find some way to raise error and exit in this case. Maybe Rails doesn't raise any error at all when generators are not found?
      def execute
        return unless Dir.exist?(app_name)

        if gems_configuration_commands.length.zero?
          return
        end

        confirm_commands_to_execute

        Dir.chdir(app_name) do
          gems_configuration_commands.each do |command|
            system! "bundle exec #{command}"
            # TODO: save progress in some file inside the user's generated app so we can continue from same point if user leaves in the middle or if app exits due to some error. Also find some way to update configurations in async without stopping any gem configuration operations (not important till MVP)
          end
        end

        # TODO: Run generators that have dynamic options here e.g. Github CI requires repository name

        run_pending_migrations
      end

      def confirm_commands_to_execute
        commands_to_display =
          gems_configuration_commands
            .map
            .with_index do |command, index|
              item_number = format("%02d", index + 1)

              "#{item_number}. #{command}"
            end
            .join("\n")

        prompt.say <<~BANNER
        \nRails app is now ready with initial configurations. Next, we will move on to configuring gems you have chosen by executing following commands:

        #{commands_to_display}
        BANNER

        continue_if? "\nContinue?"
      end

      def run_pending_migrations
        Dir.chdir(app_name) { system! "bin/rails db:migrate" }
      end

      private

      attr_reader :app_name, :gems_configuration_commands

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
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
