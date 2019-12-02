module Rviz
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return javascript_include_tag('rviz.js', :plugin => 'rviz')
      end
    end
  end
end


############### FOR MARKDOWN ##################################################
require 'cgi'

module Redmine
  module WikiFormatting
    module Markdown
      class HTML < Redcarpet::Render::HTML
        include ActionView::Helpers::TagHelper
        include Redmine::Helpers::URL

        def link(link, title, content)
          return nil unless uri_with_safe_scheme?(link)

          css = nil
          unless link && link.starts_with?('/')
            css = 'external'
          end
          content_tag('a', content.to_s.html_safe, :href => link, :title => title, :class => css)
        end

        def block_code(code, language)
          if language.present? && Redmine::SyntaxHighlighting.language_supported?(language)
            "<pre><code class=\"#{CGI.escapeHTML language} syntaxhl\">" +
              Redmine::SyntaxHighlighting.highlight_by_language(code, language) +
              "</code></pre>"
          else
            "<pre class=\"#{CGI.escapeHTML language}\">" + CGI.escapeHTML(code) + "</pre>"
          end
        end

        def image(link, title, alt_text)
          return unless uri_with_safe_scheme?(link)

          tag('img', :src => link, :alt => alt_text || "", :title => title)
        end
      end

      class Formatter
        include Redmine::WikiFormatting::LinksHelper
        alias :inline_restore_redmine_links :restore_redmine_links

        def initialize(text)
          @text = text
        end

        def to_html(*args)
          html = formatter.render(@text)
          html = inline_restore_redmine_links(html)
          html
        end

        def get_section(index)
          section = extract_sections(index)[1]
          hash = Digest::MD5.hexdigest(section)
          return section, hash
        end

        def update_section(index, update, hash=nil)
          t = extract_sections(index)
          if hash.present? && hash != Digest::MD5.hexdigest(t[1])
            raise Redmine::WikiFormatting::StaleSectionError
          end
          t[1] = update unless t[1].blank?
          t.reject(&:blank?).join "\n\n"
        end

        def extract_sections(index)
          sections = [+'', +'', +'']
          offset = 0
          i = 0
          l = 1
          inside_pre = false
          @text.split(/(^(?:.+\r?\n\r?(?:\=+|\-+)|#+.+|(?:~~~|```).*)\s*$)/).each do |part|
            level = nil
            if part =~ /\A(~{3,}|`{3,})(\s*\S+)?\s*$/
              if !inside_pre
                inside_pre = true
              elsif !$2
                inside_pre = false
              end
            elsif inside_pre
              # nop
            elsif part =~ /\A(#+).+/
              level = $1.size
            elsif part =~ /\A.+\r?\n\r?(\=+|\-+)\s*$/
              level = $1.include?('=') ? 1 : 2
            end
            if level
              i += 1
              if offset == 0 && i == index
                # entering the requested section
                offset = 1
                l = level
              elsif offset == 1 && i > index && level <= l
                # leaving the requested section
                offset = 2
              end
            end
            sections[offset] << part
          end
          sections.map(&:strip)
        end

        private

        def formatter
          @@formatter ||= Redcarpet::Markdown.new(
            Redmine::WikiFormatting::Markdown::HTML.new(
              :filter_html => true,
              :hard_wrap => true
            ),
            :autolink => true,
            :fenced_code_blocks => true,
            :space_after_headers => true,
            :tables => true,
            :strikethrough => true,
            :superscript => true,
            :no_intra_emphasis => true,
            :footnotes => true,
            :lax_spacing => true,
            :underline => true
          )
        end
      end
    end
  end
end


############### FOR TEXTILE ##################################################
require File.expand_path('../redcloth3', __FILE__)
require 'digest/md5'

module Redmine
  module WikiFormatting
    module Textile
      class Formatter < RedCloth3
        include ActionView::Helpers::TagHelper
        include Redmine::WikiFormatting::LinksHelper

        alias :inline_auto_link :auto_link!
        alias :inline_auto_mailto :auto_mailto!
        alias :inline_restore_redmine_links :restore_redmine_links

        # auto_link rule after textile rules so that it doesn't break !image_url! tags
        RULES = [:textile, :block_markdown_rule, :inline_auto_link, :inline_auto_mailto, :inline_restore_redmine_links]

        def initialize(*args)
          super
          self.hard_breaks=true
          self.no_span_caps=true
          self.filter_styles=false
        end

        def to_html(*rules)
          @toc = []
          super(*RULES).to_s
        end

        def get_section(index)
          section = extract_sections(index)[1]
          hash = Digest::MD5.hexdigest(section)
          return section, hash
        end

        def update_section(index, update, hash=nil)
          t = extract_sections(index)
          if hash.present? && hash != Digest::MD5.hexdigest(t[1])
            raise Redmine::WikiFormatting::StaleSectionError
          end
          t[1] = update unless t[1].blank?
          t.reject(&:blank?).join "\n\n"
        end

        def extract_sections(index)
          @pre_list = []
          text = self.dup
          rip_offtags text, false, false
          before = +''
          s = +''
          after = +''
          i = 0
          l = 1
          started = false
          ended = false
          text.scan(/(((?:.*?)(\A|\r?\n\s*\r?\n))(h(\d+)(#{A}#{C})\.(?::(\S+))?[ \t](.*?)$)|.*)/m).each do |all, content, lf, heading, level|
            if heading.nil?
              if ended
                after << all
              elsif started
                s << all
              else
                before << all
              end
              break
            end
            i += 1
            if ended
              after << all
            elsif i == index
              l = level.to_i
              before << content
              s << heading
              started = true
            elsif i > index
              s << content
              if level.to_i > l
                s << heading
              else
                after << heading
                ended = true
              end
            else
              before << all
            end
          end
          sections = [before.strip, s.strip, after.strip]
          sections.each {|section| smooth_offtags_without_code_highlighting section}
          sections
        end

        private

        # Patch for RedCloth.  Fixed in RedCloth r128 but _why hasn't released it yet.
        # <a href="http://code.whytheluckystiff.net/redcloth/changeset/128">http://code.whytheluckystiff.net/redcloth/changeset/128</a>
        def hard_break( text )
          text.gsub!( /(.)\n(?!\n|\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br />" ) if hard_breaks
        end

        alias :smooth_offtags_without_code_highlighting :smooth_offtags
        # Patch to add code highlighting support to RedCloth
        def smooth_offtags( text )
          unless @pre_list.empty?
            ## replace <pre> content
            text.gsub!(/<redpre#(\d+)>/) do
              content = @pre_list[$1.to_i]
              if content.match(/<code\s+class=["'](\w+)["']>\s?(.+)/m)
                language = $1
                text = $2
                if Redmine::SyntaxHighlighting.language_supported?(language)
                  text.gsub!(/x%x%/, '&')
                  content = "<code class=\"#{language} syntaxhl\">" +
                    Redmine::SyntaxHighlighting.highlight_by_language(text, language)
                else
                  content = "<code class=\"#{language}\">#{ERB::Util.h(text)}"
                end
              end
              content
            end
          end
        end
      end
    end
  end
end
