require 'pp'
require 'time'
require 'date'
require 'fileutils'

require 'uri'
require 'net/http'
require 'net/https'

require 'json'
require 'yaml'


###
# our own 3rd party libs
require 'fetcher'



module Webcache


 class Configuration
    ## root directory - todo/check: find/use a better name - why? why not?
    def root()       @root || './dl'; end
    def root=(value) @root = value; end
 end # class Configuration


 ## lets you use
 ##   Webcache.configure do |config|
 ##      config.root = './cache'
 ##   end

 def self.configure()  yield( config ); end

 def self.config()  @config ||= Configuration.new;  end


 ## add "high level" root convenience helpers
 def self.root()       config.root; end
 def self.root=(value) config.root = value; end


 ### "interface" for "generic" cache storage (might be sqlite database or filesystem)
 def self.cache() @cache ||= DiskCache.new; end

 def self.record( url, response )  cache.record( url, response ); end
 def self.cached?( url ) cache.cached?( url ); end
 class << self
   alias_method :exist?, :cached?
 end



class DiskCache
  def cached?( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    File.exist?( body_path )
  end
  alias_method :exist?, :cached?

  def record( url, response )  ## add more save / put / etc. aliases - why? why not?

    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    meta_path = "#{body_path}.meta.txt"

    ## make sure path exits
    FileUtils.mkdir_p( File.dirname( body_path ) )


    ## note - for now always assume utf8!!!!!!!!!
    body = response.body.to_s
    body = body.force_encoding( Encoding::UTF_8 )

    File.open( body_path, 'w:utf-8' ) {|f| f.write( body ) }

    File.open( meta_path, 'w:utf-8' ) do |f|
      response.each_header do |key, value|  # Iterate all response headers.
        f.write( "#{key}: #{value}" )
        f.write( "\n" )
      end
    end
  end


  ### helpers
  def url_to_path( str )
    ## map url to file path
    uri = URI.parse( str )

    ## note: ignore scheme (e.g. http/https)
    ##         and  post  (e.g. 80, 8080, etc.) for now
    ##    always downcase for now (internet domain is case insensitive)
    host_dir = uri.host.downcase

    ## "/this/is/everything?query=params"
    ##   cut-off leading slash and
    ##    convert query ? =
    req_path = uri.request_uri[1..-1]



    ### special "prettify" rule for weltfussball
    ##   /eng-league-one-2019-2020/  => /eng-league-one-2019-2020.html
    if (host_dir.index( 'weltfussball.de' ) ||
        host_dir.index( 'worldfootball.net' )
       ) && req_path.end_with?( '/' )
         req_path = "#{req_path[0..-2]}.html"
    end

    page_path = "#{host_dir}/#{req_path}"
    page_path
  end
end # class DiskCache


end  # module Webcache




## add convenience alias for camel case / alternate different spelling
WebCache = Webcache