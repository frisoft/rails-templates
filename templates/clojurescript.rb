#
# Rails template to build a rails application with a clojurescript frontend.
#
# Author: Andrea Frigido
# License: The MIT License (MIT)
#

RED="\e[31m"
NONE="\e[0m"
FRONTEND_PROJECT='frontend/project.clj'
APP_DIV = "<!-- this is where your frontend component will be included -->\n  <div id=\"app\"></div>"

def command?(cmd)
  unless system("command -v #{cmd} >/dev/null 2>&1")
    puts "#{RED}#{cmd} is not installed. Please install it first!#{NONE}"
    exit 1
  end
end

command?('lein')

def setup_frontend
  run "lein new figwheel frontend -- --reagent"
  gsub_file FRONTEND_PROJECT,
    ':output-to "resources/public/js/compiled/frontend.js"',
    ':output-to "../app/assets/javascripts/frontend.js"'
  gsub_file FRONTEND_PROJECT,
    ':asset-path "js/compiled/out"',
    ':asset-path "/assets"'
  append_file '.gitignore',
    "app/assets/javascripts/frontend.js\n"+
    "frontend/resources/public/js/compiled/out\n"+
    "frontend/target"
end

def setup_rails
  application "config.assets.paths << Rails.root.join('frontend', 'resources', 'public', 'js', 'compiled', 'out')"
  gsub_file 'app/views/layouts/application.html.erb', /\<html\>(.*)<\/html\>/m do |match|
    js = match.scan(/^\s*<%= javascript_include_tag (?:['"])application(?:['"])(?:[^%]*)\%\>/).first
    if match =~ /#{APP_DIV}/
      match
    else
      match.gsub(js, '').gsub('</body>',"  #{APP_DIV}\n#{js}\n</body>")
    end
  end
  generate 'controller', 'TestPage index'
end

def message
  puts "\n"
  puts "run the rails app: bundle rails s"
  puts "cd frontend"
  puts "run frontend: lein frigwheel"
  puts "visit http://localhost:3000/test_page/index"
  puts "\n"
end

def setup
  setup_frontend
  setup_rails
  message
end

# rails new project -m template
after_bundle do
  setup
end

# bundle exec rake rails:template LOCATION=template
if ENV['LOCATION']
  #run "bundle install"
  setup
end
