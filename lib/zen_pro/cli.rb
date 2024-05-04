require "thor"

require_relative "commands/generate"
require_relative "commands/configure"

module ZenPro
  class CLI < Thor
    map "g" => :generate
    map %w[-v --version] => "version"

    desc "create project and configure gems",
         "Generate a Rails app and configure gems using Project Template configurations"
    def generate(project_template_id)
      Commands::Generate.run(project_template_id, options)
    end

    desc "version", "Display gem version", hide: true
    def version
      say "zen_pro/#{VERSION} #{RUBY_DESCRIPTION}"
    end
  end
end
