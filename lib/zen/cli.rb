require "thor"

require_relative "commands/generate"
require_relative "commands/configure"

module Zen
  class CLI < Thor
    map "g" => :generate
    map %w[-v --version] => "version"

    desc "create project and configure gems",
         "Generate a Rails app and configure gems using Project Template configurations"
    def generate(project_template_id)
      Commands::Generate.run(project_template_id, options)
    end

    desc "configure gems",
         "Configure gems inside already generated Rails app using Project Template configurations"
    def configure(project_template_id, app_path)
      Commands::Configure.run(project_template_id, app_path, options)
    end

    desc "version", "Display gem version", hide: true
    def version
      say "zen/#{VERSION} #{RUBY_DESCRIPTION}"
    end
  end
end
