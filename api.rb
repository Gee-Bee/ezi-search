require_relative 'config'
require 'sinatra'

$results = []

get '/' do
  $results = $search_engine.search(params[:q])
  template
end

def template
  <<-HTML
    <html>
      <body>
        <form action='/' method='get'>
          Query: <input name='q'>
          <button type='submit'>Search</button>
        </form>
        #{results_html}
      </body>
    </html>
  HTML
end

def results_html
  $results.map do |result|
    "<div>#{result[:content][/[^\r\n]+/]}; #{result[:sim_tf_idf].to_f}</div>"
  end.join('<br/>')
end
