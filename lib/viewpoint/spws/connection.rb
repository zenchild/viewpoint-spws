class Viewpoint::SPWS::Connection
  include Viewpoint::SPWS

  attr_reader :site_base, :server_timezone
  # @param [String] site_base the base URL of the site not including the
  #   web service part.
  #   @example https://<site>/mysite/<default.aspx>
  # @param [TZInfo::Timezone] server_tz Timezone Sharepoint WFE is set to.
  def initialize(site_base, server_tz = nil)
    @log = Logging.logger[self.class.name.to_s.to_sym]
    @httpcli = HTTPClient.new
    # Up the keep-alive so we don't have to do the NTLM dance as often.
    @httpcli.keep_alive_timeout = 60
    @site_base = URI.parse(normalize_site_name(site_base))
    @server_timezone = server_tz
  end

  def set_auth(user,pass)
    @httpcli.set_auth(@site_base.to_s, user, pass)
  end

  # Authenticate to the web service. You don't have to do this because
  # authentication will happen on the first request if you don't do it here.
  # @return [Boolean] true if authentication is successful, false otherwise
  def authenticate(websvc)
    self.get(websvc) && true
  end

  # Send a GET to the web service
  # @return [String] If the request is successful (200) it returns the body of
  #   the response.
  def get(websvc)
    check_response( @httpcli.get(@site_base + URI.encode(websvc)) )
  end

  # Send a POST to the web service
  # @return [String] If the request is successful (200) it returns the body of
  #   the response.
  def post(websvc, xmldoc)
    headers = {'Content-Type' => 'application/soap+xml; charset=utf-8'}
    url = (@site_base + websvc).to_s
    check_response( @httpcli.post(url, xmldoc, headers) )
  end

  private


  # @param [String] site an unnormalized site
  # @return [String] a normalized site base
  def normalize_site_name(site)
    site = site.sub(/default.aspx$/i,'')
    site.end_with?('/') ? site : site << '/'
  end

  def check_response(resp)
    @log.debug "HTTP Response: #{resp.status}"
    case resp.status
    when 200
      resp.body
    when 302
      # @todo redirect
      raise "Unhandled HTTP Redirect"
    when 500
      if resp.headers['Content-Type'].include?('xml')
        err_string, err_code = parse_soap_error(resp.body)
        raise "SOAP Error: Message: #{err_string}  Code: #{err_code}"
      else
        raise "Internal Server Error. Message: #{resp.body}"
      end
    else
      raise "HTTP Error Code: #{resp.status}, Msg: #{resp.body}"
    end
  end

  # @param [String] xml to parse the errors from.
  def parse_soap_error(xml)
    ndoc = Nokogiri::XML(xml)
    ns = ndoc.collect_namespaces
    err_string  = ndoc.xpath("//xmlns:errorstring",ns).text
    err_code    = ndoc.xpath("//xmlns:errorcode",ns).text
    @log.debug "Internal SOAP error. Message: #{err_string}, Code: #{err_code}"
    [err_string, err_code]
  end

end
