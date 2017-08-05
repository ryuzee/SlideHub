# -*- coding: utf-8 -*-
require "#{File.dirname(__FILE__)}/../../lib/slide_hub/version"
require 'open3'

namespace :docker do
  task :default => :build

  task :build_base do
    Dir.chdir("#{File.dirname(__FILE__)}/../../docker-images/base") do
      cmd = 'docker build --no-cache=true -t ryuzee/slidehub-base .'
      sh cmd
    end
  end

  task :push_base do
    Dir.chdir("#{File.dirname(__FILE__)}/../../docker-images/base") do
      cmd = 'docker push ryuzee/slidehub-base:latest'
      sh cmd
    end
  end

  task :build do
    Dir.chdir("#{File.dirname(__FILE__)}/../../") do
      cmd = "docker build -q -t ryuzee/slidehub:latest . 2>/dev/null | awk '/Successfully built/{print $NF}'"
      o, e, _s = Open3.capture3(cmd)
      if o.chomp! == '' || e != ''
        raise 'Failed to build Docker image...'
      end

      cmd = "docker tag ryuzee/slidehub:latest ryuzee/slidehub:#{SlideHub::VERSION}"
      o, e, _s = Open3.capture3(cmd)
      if o.chomp! == '' || e != ''
        raise 'Failed to add version tag to Docker image...'
      end
    end
  end

  task :push do
    Dir.chdir("#{File.dirname(__FILE__)}/../../") do
      cmd = 'docker push ryuzee/slidehub:latest'
      sh cmd
      cmd = "docker push ryuzee/slidehub:#{SlideHub::VERSION}"
      sh cmd
    end
  end
end

# vim: filetype=ruby
