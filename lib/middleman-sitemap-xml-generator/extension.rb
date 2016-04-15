module Middleman
  module SitemapXmlGenerator
    class Extension < ::Middleman::Extension
      option :default_changefreq, 'monthly', 'Default page priority'
      option :default_priority, 0.5, 'Default page priority'
      option :sitemap_xml_path, 'sitemap.xml', 'Path to the sitemap.xml'
      option :exclude_attr, 'hide_from_sitemap', 'Attribute in Frontmatter to exclude from sitemap'
      option :process_url, nil, 'Callable object(responds to #call) to process a URL'
      option :process_changefreq, nil, 'Callable object to determine a changefreq'
      option :process_priority, nil, 'Callable object to determine a priority'
      option :exclude_if, ->(resource) { false }, 'Callable object to exclude from the sitemap'
      option :extra_ext, [], 'Extensions allowed to be in the sitemap(needed prefixed "dot")'
      option :discard_ext, [], 'Extensions removed from "loc" in the sitemap(needed prefixed "dot")'

      TEMPLATES_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))


      def initialize(app, options_hash={}, &block)
        super

        require 'builder'
      end


      public


      #
      # Hooks
      #

      def after_configuration
        register_extension_templates
        prepare_extra_ext_opt
        prepare_discard_ext_opt
        watch_vendor_directory
      end

      def manipulate_resource_list(resources)
        resources << sitemap_resource
      end


      #
      # Helpers
      #

      def resource_in_sitemap?(resource)
        is_page?(resource) && not_excluded?(resource)
      end

      def process_changefreq(path)
        default = options.default_changefreq
        options.process_changefreq ? options.process_changefreq.call(path, default) : default
      end

      def process_priority(path)
        default = options.default_priority
        options.process_priority ? options.process_priority.call(path, default) : default
      end

      def process_url(path)
        path = process_extension path
        options.process_url ? options.process_url.call(path) : path
      end

      helpers do
        def resources_for_sitemap
          sitemap.resources.select do |resource|
            extensions[:sitemap_xml_generator].resource_in_sitemap?(resource)
          end
        end
      end


      #
      # Internals
      #

      private

      def allowed_ext?(resource)
        options.extra_ext.include? File.extname(resource.path)
      end

      def filter_valid_extension(value)
        [value].flatten.select { |ext| ext.match /^\.[^.]+/ }
      end

      def generate_processor(method_name)
        self.class.instance_method(method_name.to_sym).bind(self)
      end

      def is_page?(resource)
        resource.path.end_with?(page_ext) || allowed_ext?(resource)
      end

      def not_excluded?(resource)
        !resource.ignored? \
          && !resource.data[options.exclude_attr] && !options.exclude_if.call(resource)
      end

      def page_ext
        File.extname(app.index_file)
      end

      def prepare_extra_ext_opt
        options.extra_ext = filter_valid_extension options.extra_ext
      end

      def prepare_discard_ext_opt
        options.discard_ext = filter_valid_extension options.discard_ext
      end

      def process_extension(path)
        target_ext = File.extname path
        if options.discard_ext.include?(target_ext)
          path = File.join(File.dirname(path), File.basename(path, target_ext))
        end
        path
      end

      def register_extension_templates
        # We call reload_path to register the templates directory with Middleman.
        # The path given to app.files must be relative to the Middleman site's root.
        templates_dir_relative_from_root = \
          Pathname(TEMPLATES_DIR).relative_path_from(Pathname(app.root))
        app.files.reload_path(templates_dir_relative_from_root)
      end

      def sitemap_locals
        {
          url_proc: generate_processor(:process_url),
          changefreq_proc: generate_processor(:process_changefreq),
          priority_proc: generate_processor(:process_priority)
        }
      end

      def sitemap_resource
        source_file = template('sitemap.xml.builder')

        ::Middleman::Sitemap::Resource.new(app.sitemap, sitemap_xml_path, source_file).tap do |res|
          res.add_metadata(options: { layout: false }, locals: sitemap_locals)
        end
      end

      def sitemap_xml_path
        options.sitemap_xml_path
      end

      def template(path)
        full_path = File.join(TEMPLATES_DIR, path)
        raise "Template #{full_path} not found" if !File.exist?(full_path)
        full_path
      end

      # Workaround for the template reference issue. See below:
      #   https://github.com/Aupajo/middleman-search_engine_sitemap/issues/5
      #   https://github.com/Aupajo/middleman-search_engine_sitemap/issues/2#issuecomment-46701165
      def watch_vendor_directory
        app.config[:file_watcher_ignore] = (app.config[:file_watcher_ignore].reject do |regexp|
          regexp == /^vendor(\/|$)/
        end)
      end

    end
  end
end
