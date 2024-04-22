require "tty-prompt"

module Zen
  module Commands
    class Configure
      def self.run(project_template_id, app_name, _options)
        new(project_template_id, app_name).execute
      end

      def initialize(project_template_id, app_name)
        @project_template_id = project_template_id
        @app_name = app_name
      end

      def execute
        # configure gems
      ensure
        # TODO: move this code to be around after configurations message in future
        Dir.chdir(app_name) do
          prompt.say "\nRemoving boring_generators gem since it's no longer required"

          system! "bundle remove boring_generators"
        end
      end

      private

      attr_reader :app_name

      def prompt
        return @prompt if defined?(@prompt)

        TTY::Prompt.new
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
