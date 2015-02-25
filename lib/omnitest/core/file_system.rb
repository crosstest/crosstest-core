module Omnitest
  module Core
    module FileSystem
      include Util::String

      class << self
        # Finds a file by loosely matching the file name to a scenario name
        def find_file(search_path, scenario_name, ignored_patterns = nil)
          ignored_patterns ||= read_gitignore(search_path)
          glob_string = "#{search_path}/**/*#{slugify(scenario_name)}.*"
          potential_files = Dir.glob(glob_string, File::FNM_CASEFOLD)
          potential_files.concat Dir.glob(glob_string.gsub('_', '-'), File::FNM_CASEFOLD)
          potential_files.concat Dir.glob(glob_string.gsub('_', ''), File::FNM_CASEFOLD)

          # Filter out ignored filesFind the first file, not including generated files
          files = potential_files.select do |f|
            !ignored? ignored_patterns, search_path, f
          end

          # Select the shortest path, likely the best match
          file = files.min_by(&:length)

          fail Errno::ENOENT, "No file was found for #{scenario_name} within #{search_path}" if file.nil?
          Pathname.new file
        end

        def relativize(file, base_path)
          absolute_file = File.absolute_path(file)
          absolute_base_path = File.absolute_path(base_path)
          Pathname.new(absolute_file).relative_path_from Pathname.new(absolute_base_path)
        end

        private

        # @api private
        def read_gitignore(dir)
          gitignore_file = "#{dir}/.gitignore"
          File.read(gitignore_file)
        rescue
          ''
        end

        # @api private
        def ignored?(ignored_patterns, base_path, target_file)
          # Trying to match the git ignore rules but there's some discrepencies.
          ignored_patterns.split.find do |pattern|
            # if git ignores a folder, we should ignore all files it contains
            pattern = "#{pattern}**" if pattern[-1] == '/'
            started_with_slash = pattern.start_with? '/'

            pattern.gsub!(/\A\//, '') # remove leading slashes since we're searching from root
            file = relativize(target_file, base_path)
            ignored = file.fnmatch? pattern
            ignored || (file.fnmatch? "**/#{pattern}" unless started_with_slash)
          end
        end
      end
    end
  end
end
