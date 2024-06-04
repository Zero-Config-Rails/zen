require "thor"

require_relative "commands/generate"
require_relative "commands/session"
require_relative "commands/configure"

module ZenPro
  class CLI < Thor
    map "g" => :generate
    map %w[-v --version] => "version"

    desc "create project and configure gems",
         "Generate a Rails app and configure gems using Project Template configurations"
    def generate(project_template_id)
      puts "Welcome to Zero Config Rails!\n\n"

      Commands::Session.new(project_template_id).login

      Commands::Generate.run(project_template_id, options)
    end

    desc "logout from the current session",
         "Logout from the current session for a particular project template"
    def logout(project_template_id)
      Commands::Session.new(project_template_id).logout
    end

    desc "version", "Display gem version", hide: true
    def version
      say "zen_pro/#{VERSION} #{RUBY_DESCRIPTION}"
    end
  end
end
