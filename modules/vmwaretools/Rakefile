# Rakefile

require 'rubygems'
require 'erb'
require 'open3'
require 'bundler'
Bundler.require(:rake)

require 'rake/clean'

desc "Check puppet module syntax."
task :syntax do
  begin
    require 'puppet/face'
  rescue LoadError
    fail 'Cannot load puppet/face, are you sure you have Puppet 2.7?'
  end

  def validate_manifest(file)
    begin
      Puppet::Face[:parser, '0.0.1'].validate(file)
    rescue Puppet::Error => error
      puts error.message
    end
  end

  puts "Checking puppet module syntax..."
  FileList['**/*.pp'].each do |manifest|
    # exclude the vendor/ dir
    next if manifest =~ /vendor/
    puts "Evaluating syntax for #{manifest}"
    validate_manifest manifest
  end
end

desc "test erb syntax"
task :erb do
  FileList['**/*.erb'].each do |template|
    # exclude the vendor/ dir
    next if template =~ /vendor/

      puts "Evaluating (erb) template syntax -  #{template}"
      Open3.popen3('ruby -Ku -c') do |stdin, stdout, stderr|
      stdin.puts(ERB.new(File.read(template), nil, '-').src)
      stdin.close
      if error = ((stderr.readline rescue false))
        puts template + error[1..-1].sub(/^[^:]*:\d+: /, '')
        exit 1
      end
      stdout.close rescue false
      stderr.close rescue false
      end
  end
end

desc "Check puppet module code style."
task :style do
  begin
    require 'puppet-lint'
  rescue LoadError
    fail 'Cannot load puppet-lint, did you install it?'
  end

  puts "Checking puppet module code style..."
  linter = PuppetLint.new
  linter.configuration.log_format = '%{path} line %{linenumber} : %{KIND} %{message}'
  linter.configuration.send("disable_80chars")

  FileList['**/*.pp'].each do |puppet_file|
    # exclude the vendor/ dir
    next if puppet_file =~ /vendor/
    puts "Evaluating code style for #{puppet_file}"
    linter.file = puppet_file
    linter.run
  end
  fail if linter.errors?
end

#TODO: this hasn't been tested yet
#
desc "Generate documentation."
task :doc do |t|
  puts "Generating puppet documentation..."
  work_dir = File.dirname(__FILE__)
  sh %{puppet doc \
    --outputdir #{work_dir}/doc \
    --mode rdoc \
    --manifestdir #{work_dir}/manifests \
    --modulepath #{work_dir}/modules \
    --manifest #{work_dir}/site.pp}

  if File.exists? "#{work_dir}/doc/files/#{work_dir}/modules"
    FileUtils.mv "#{work_dir}/doc/files/#{work_dir}", "#{work_dir}/doc/files"
  end
  Dir.glob('./**/*.*').each do |file|
    if File.file? "#{file}"
      sh %{sed -i "s@#{work_dir}/@/@g" "#{file}"}
    end
  end
end
