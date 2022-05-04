require 'rails_helper'
require 'io'

describe 'Class IO' do
  path = "#{File.dirname(File.dirname(__FILE__))}/fixtures/dummy.txt"

  describe 'tail' do
    it 'works' do
      File.open(path) do |io|
        io.tail(1).each do |line|
          expect(line).to eq("DUMMY005\n")
        end
      end
    end

    it 'gets all lines' do
      lines = ''
      File.open(path) do |io|
        lines = io.tail(6)
      end
      expect(lines).to eq(%W[DUMMY001\n DUMMY002\n DUMMY003\n DUMMY004\n DUMMY005\n])
    end
  end

  describe 'head' do
    it 'works' do
      File.open(path) do |io|
        io.head(1).each do |line|
          expect(line).to eq("DUMMY001\n")
        end
      end
    end

    it 'gets all lines' do
      lines = ''
      File.open(path) do |io|
        lines = io.head(6)
      end
      expect(lines).to eq(%W[DUMMY001\n DUMMY002\n DUMMY003\n DUMMY004\n DUMMY005\n])
    end
  end
end
