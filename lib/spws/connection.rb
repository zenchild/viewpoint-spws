class Viewpoint::SPWS::Connection
  include Viewpoint::SPWS

  # @param [String] site_base the base URL of the site not including the
  #   web service part.
  #   @example https://<site>/personal/myname
  def initialize(site_base)
    @httpcli = HTTPClient.new
    site_base = site_base.end_with?('/') ? site_base : site_base << '/'
    @site_base = URI.parse(site_base)
  end

  def set_auth(user,pass)
    @httpcli.set_auth(@site_base.to_s, user, pass)
  end

  def lists_ws
    Lists.new(self)
  end

  # Authenticate to the web service
  # @return [Boolean] true if authentication is successful, false otherwise
  def authenticate(websvc)
    self.get(websvc) && true
  end

  # Send a GET to the web service
  # @return [String] If the request is successful (200) it returns the body of
  #   the response.
  def get(websvc)
    check_response( @httpcli.get(@site_base + websvc) )
  end

  # Send a POST to the web service
  # @return [String] If the request is successful (200) it returns the body of
  #   the response.
  def post(websvc, xmldoc)
    headers = {'Content-Type' => 'text/xml; charset=utf-8'}
    url = (@site_base + websvc).to_s
    check_response( @httpcli.post(url, xmldoc, headers) )
  end


  private

  def check_response(resp)
    case resp.status
    when 200
      resp.body
    else
      raise "HTTP Error Code: #{resp.status}, Msg: #{resp.body}"
    end
  end

end
