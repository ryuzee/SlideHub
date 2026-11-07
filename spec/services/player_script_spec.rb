require 'rails_helper'

RSpec.describe PlayerScript do
  let(:template) do
    <<~JS
      var OSSJSPARTS = {};
      OSSJSPARTS.currentPageIndex = SLIDEHUB_START_INDEX;
      OSSJSPARTS.classPrefix = "PREFIX";
      OSSJSPARTS.moveTo = function(index) { var longLocalName = index + 1; return longLocalName; };
    JS
  end

  before { described_class.clear }

  it 'fills in the prefix and the start page in the minified script' do
    script = described_class.build(template, prefix: 'jsabc', start_index: 4)
    expect(script).to include('OSSJSPARTSjsabc.currentPageIndex=4', 'classPrefix="jsabc"')
    expect(script).not_to include(PlayerScript::START_INDEX, 'OSSJSPARTS.', 'longLocalName')
  end

  it 'minifies a template only once, whatever the prefix and the start page' do
    expect(Uglifier).to receive(:new).once.and_call_original
    first = described_class.build(template, prefix: 'jsone', start_index: 0)
    second = described_class.build(template, prefix: 'jstwo', start_index: 9)
    expect(first).to include('OSSJSPARTSjsone.currentPageIndex=0')
    expect(second).to include('OSSJSPARTSjstwo.currentPageIndex=9')
  end

  it 'minifies again when the template changes' do
    expect(Uglifier).to receive(:new).twice.and_call_original
    described_class.build(template, prefix: 'jsone', start_index: 0)
    described_class.build("#{template}\nOSSJSPARTS.version = 2;", prefix: 'jsone', start_index: 0)
  end
end
