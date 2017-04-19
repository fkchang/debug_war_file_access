require 'bundler'
Bundler.require
$: << '.'
require 'sinatra'
require 'sinatra/flash'
require 'sinatra/logger'

if production?
  puts "\n\n\nPROD"
else
  puts "\n\n\nNOT PROD"
end


# monkey patch into classic mode the logger
class Rack::Builder
  include ::SemanticLogger::Loggable
end

# do logger setup
LOGFILE_NAME = "log/#{settings.environment}.log"
class Sinatra::Application
  logger filename: LOGFILE_NAME, level: :trace

end


['/logs', '/logs/:filename', '/logs/tail/:filename'].each { |route|
  before route do
    get_log_files
  end
}

helpers do

  def form_method(method)
    case method
    when 'put', 'delete'
      'post'
    else
      method
    end
  end
  
  def post_button(method, action, value, color='', onclick_text=nil, disabled=nil)
    special_methods = %w(put delete)
    haml_tag :form, :method  => form_method(method), :action => action do
      input_params = {
        :class => "btn btn-sm #{color}",
        :type => 'submit',
        :value => value
      }
      haml_tag(:input, name: '_method', type: 'hidden', value: method) if special_methods.include?(method)      
      input_params.merge!( onclick: "return confirm('#{onclick_text}')") if onclick_text
      input_params.merge!( disabled: true) if disabled
      haml_tag :input, input_params
      
    end
  end
  
  def full_path(filename)
    "#{LOG_PREFIX}/#{filename}"
  end

  def get_log_files
    @files = Dir["#{LOG_PREFIX}/*"].map { |f| f.split('/').last }
  end

  def escape_to_html(data)
    { 1 => :nothing,
      2 => :nothing,
      4 => :nothing,
      5 => :nothing,
      7 => :nothing,
      30 => :black,
      31 => :red,
      32 => :green,
      33 => :yellow,
      34 => :blue,
      35 => :magenta,
      36 => :cyan,
      37 => :white,
      40 => :nothing,
      41 => :nothing,
      43 => :nothing,
      44 => :nothing,
      45 => :nothing,
      46 => :nothing,
      47 => :nothing,
    }.each do |key, value|
      if value != :nothing
        data.gsub!(/\e\[#{key}m/,"<span style=\"color:#{value}\">")
      else
        data.gsub!(/\e\[#{key}m/,"<span>")
      end
    end
    data.gsub!(/\e\[0m/,'</span>')
    return data
  end  

end

LOG_PREFIX = './log/'
get '/logs' do
  logger.info "Files = #{@files.inspect}"
  haml :'logs/index'
end

get '/logs/download/:filename' do
  filename =  params[:filename]
  logger.info "Sending #{filename}"
  send_file full_path(filename), :filename => filename, :type => "Applicaiton/octet-stream"
  flash[:info] = "Downloaded #{filename}"
  redirect to('/logs')
end


get '/logs/:filename' do
  filename =  params[:filename]
  @output = escape_to_html File.read(full_path(filename))
  haml :'logs/index'
end

get '/logs/tail/:filename' do
  filename =  params[:filename]
  @output = escape_to_html `tail -n 100 #{full_path(filename)}`
  haml :'logs/index'
end

delete '/logs/delete/:filename' do
  filename =  params[:filename]
  
  if filename == File.basename(LOGFILE_NAME)
    logger.warn "Rejecting attempt to delete current file"
    flash[:warning] = "You cannot delete the current log"
  else
    logger.warn "Deleting #{filename}"
    File.delete(full_path(filename)) 
    flash[:warning] = "Deleted #{filename}"
  end
  redirect to('/logs')
end


run Sinatra::Application
