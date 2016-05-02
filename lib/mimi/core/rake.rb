module Mimi
  module Core
    module Rake
      def self.load_rake_tasks
        app_and_modules_paths = [Mimi.app_root_path] + Mimi.loaded_modules_paths
        rakefiles = app_and_modules_paths.map do |path|
          Pathname.glob(path.join('lib', 'tasks', '**', '*.rake'))
        end.flatten
        rakefiles.each do |rakefile|
          load rakefile
        end
      end
    end # module Rake
  end # module Core
end # module Mimi

Mimi::Core::Rake.load_rake_tasks if defined?(Mimi::Core::Module)
