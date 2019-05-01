require "#{File.dirname(__FILE__)}/../../lib/slide_hub/version"
require 'open3'

BASE_CONTAINER_VERSION = '20190501'.freeze

namespace :docker do
  task :default => :build

  task :build_base do
    Dir.chdir("#{File.dirname(__FILE__)}/../../docker-images/base") do
      cmd = 'docker build --no-cache=true -t ryuzee/slidehub-base:latest .'
      sh cmd
    end

    cmd = "docker tag ryuzee/slidehub-base:latest ryuzee/slidehub-base:#{BASE_CONTAINER_VERSION}"
    o, e, _s = Open3.capture3(cmd)
    if o.chomp! == '' || e != ''
      raise 'Failed to add version tag to Docker image...'
    end
  end

  task :push_base do
    Dir.chdir("#{File.dirname(__FILE__)}/../../docker-images/base") do
      cmd = "docker push ryuzee/slidehub-base:#{BASE_CONTAINER_VERSION}"
      sh cmd
    end
  end

  task :build do
    Dir.chdir("#{File.dirname(__FILE__)}/../../") do
      cmd = if ENV.fetch('experiment') { 0 }.to_i.zero?
              "docker build -q -t ryuzee/slidehub:#{SlideHub::VERSION} -t ryuzee/slidehub:latest . 2>/dev/null | awk '/Successfully built/{print $NF}'"
            else
              "docker build -q -t ryuzee/slidehub:#{SlideHub::VERSION} . 2>/dev/null | awk '/Successfully built/{print $NF}'"
            end
      o, e, _s = Open3.capture3(cmd)
      if o.chomp! == '' || e != ''
        raise 'Failed to build Docker image...'
      end
    end
  end

  task :push do
    Dir.chdir("#{File.dirname(__FILE__)}/../../") do
      if ENV.fetch('experiment') { 0 }.to_i.zero?
        cmd = 'docker push ryuzee/slidehub:latest'
        sh cmd
      end
      cmd = "docker push ryuzee/slidehub:#{SlideHub::VERSION}"
      sh cmd
    end
  end
end

# vim: filetype=ruby
