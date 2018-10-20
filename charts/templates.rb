require 'erb'

module Charts
  ##
  # Template helpers
  class Template
    attr_reader :name

    def initialize(params = {})
      @name = params[:name] || raise('No name provided for template')
    end

    def render(params = {})
      template.result_with_hash(params)
    end

    def self.template_dir
      @template_dir ||= File.join(
        File.dirname(__FILE__),
        'assets'
      )
    end

    private

    def template
      @template ||= ERB.new(File.read(template_file_path), nil, '<>')
    end

    def template_file_name
      @template_file_name ||= "#{name}.erb"
    end

    def template_file_path
      @template_file_path ||= File.join(
        Template.template_dir, template_file_name
      )
    end
  end
end
