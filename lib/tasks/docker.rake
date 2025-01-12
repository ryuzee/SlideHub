require "#{File.dirname(__FILE__)}/../../lib/slide_hub/version"
require 'open3'

namespace :docker do
  task :default => :build

  def execute_command(cmd)
    o, e, s = Open3.capture3(cmd)
    unless s.success?
      raise "Command failed: #{cmd}\nError: #{e}"
    end

    o.strip
  end

  def buildx_instance
    # buildxインスタンスが存在するか確認
    output = execute_command('docker buildx ls')
    active_builder = output.lines.find { |line| line.include?('*') } # 現在のビルダーを検出

    if active_builder
      builder_name = active_builder.split.first.strip
      puts "Using existing buildx instance: #{builder_name}"
    else
      puts 'Creating a new unnamed buildx instance...'
      execute_command('docker buildx create --use')
    end
  end

  task :build do
    Dir.chdir("#{File.dirname(__FILE__)}/../../") do
      # Buildxインスタンスの確認と作成
      buildx_instance

      tags = ["-t ryuzee/slidehub:#{SlideHub::Version}"]
      tags << '-t ryuzee/slidehub:latest' if ENV.fetch('latest', 0).to_i == 1

      cmd = "docker buildx build --platform linux/amd64 --load -q #{tags.join(' ')} ."
      puts "Running build command: #{cmd}"

      # awkを含むコマンドの実行
      _, status = Open3.capture2(cmd)
      unless status.success?
        raise 'Failed to build Docker image: No output from build command.'
      end

      puts 'Build successful'
    end
  end

  task :push do
    Dir.chdir("#{File.dirname(__FILE__)}/../../") do
      tags = ["ryuzee/slidehub:#{SlideHub::Version}"]
      tags << 'ryuzee/slidehub:latest' if ENV.fetch('latest', 0).to_i == 1

      tags.each do |tag|
        cmd = "docker push #{tag}"
        puts "Pushing image: #{tag}"
        execute_command(cmd)
      end
    end
  end
end

# vim: filetype=ruby
