#!/usr/bin/ruby

def existent_partials root
  partials = []
  each_file(root) do |file|
    if file =~ /^.*\/_.*$/
      partials << file.strip
    end
  end

  partials.sort
end

def used_partials root
  partials = []
  each_file(root) do |file|
    File.open(file).readlines.each do |line|
      line.strip!
      if line =~ /:partial\s+=>\s+\"([a-zA-Z_\/]+)\"/
        match = $1
        if match[0] == ?/ or match[0] == '/'
          match = match[1..-1]
        end

        if match.index("/")

          path = match.split('/')[0...-1].join('/')
          file_name = "_#{match.split('/')[-1]}"

          full_path = "app/views/#{path}/#{file_name}"
        else
          if file =~ /app\/controllers\/(.*)_controller.rb/
            full_path = "app/views/#{$1}/_#{match}"
          else
            full_path = "#{file.split('/')[0...-1].join('/')}/_#{match}"
          end
        end
        partials << check_extension_path(full_path)
      end
    end
  end
  partials.uniq.sort
end

def check_extension_path(file)
  if File.exists? file + ".html.erb"
    file += ".html.erb"
  elsif File.exists? file + ".html.haml"
    file += ".html.haml"
  else
    # FUUUUUUUUUUU)!!!!!!onze1111!centoeonze
    file += ".rhtml"
  end
  file
end

def each_file(root, &block)
  files = Dir.glob("#{root}/*")
  files.each do |file|
    if File.directory? file
      each_file(file) {|file| yield file}
    else
      yield file
    end
  end
end

existent = existent_partials("app").sort
used = used_partials("app").sort

if (existent & used) == existent
else
  unused = (existent - (existent & used))
  puts unused * "\n"
end