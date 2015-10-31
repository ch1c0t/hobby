class Hobby::Router
  class Pattern
    def initialize path, route
      @route = route

      @params_keys = []
      @regexp = /^#{path.gsub(/:\w+/) do |match|
        @params_keys << match[1..-1].to_sym
        '([^/?#]+)'
      end}$/
    end

    def [] path
      match = @regexp.match path
      params = @params_keys.zip(match.captures).to_h if match
      params ? [@route, params] : nil
    end
  end
end
