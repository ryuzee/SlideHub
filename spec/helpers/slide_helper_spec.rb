require 'spec_helper'
require 'digest/md5'

describe SlideHelper do
  describe 'get_signing_key' do
    it 'returns true' do
      expected = 'a8a38db0c44e3f2b269d6468dbbb4c55'
      expect(Digest::MD5.hexdigest(helper.get_signing_key('20150101', 'ap-northeast-1', 's3', 'abcde'))).to eq(expected.to_s)
    end
  end

  describe 'populate_policy' do
    it 'returns array' do
      base_time = Time.utc(2016, 1, 1, 23, 59, 59, 0)
      access_id = 'AKIHOGEHOGE'
      secret_key = 'Secret'
      security_token = ''
      region = 'ap-northeast-1'
      bucket_name = 'sushi'
      value =  helper.populate_policy(base_time, access_id, secret_key, security_token, region, bucket_name)
      expect(value['signature']).to eq('d3737356a01471adab35e87d768d8d23af17d3e30b0d66b08c9037447271fb93')
      expect(value['date_ymd']).to eq('20160101')
      expect(value['date_gm']).to eq('20160101T235959Z')
      p  = 'eyJleHBpcmF0aW9uIjoiMjAxNi0wMS0wMlQwMTo1OTo1OVoiLCJjb25kaXRp'
      p += 'b25zIjpbeyJidWNrZXQiOiJzdXNoaSJ9LFsic3RhcnRzLXdpdGgiLCIka2V5'
      p += 'IiwiIl0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LHsic3VjY2Vzc19hY3Rpb25f'
      p += 'c3RhdHVzIjoiMjAxIn0sWyJzdGFydHMtd2l0aCIsIiRDb250ZW50LVR5cGUi'
      p += 'LCJhcHBsaWNhdGlvbi9vY3RldHN0cmVhbSJdLHsieC1hbXotbWV0YS11dWlk'
      p += 'IjoiMTQzNjUxMjM2NTEyNzQifSxbInN0YXJ0cy13aXRoIiwiJHgtYW16LW1l'
      p += 'dGEtdGFnIiwiIl0seyJ4LWFtei1jcmVkZW50aWFsIjoiQUtJSE9HRUhPR0Uv'
      p += 'MjAxNjAxMDEvYXAtbm9ydGhlYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4'
      p += 'LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1k'
      p += 'YXRlIjoiMjAxNjAxMDFUMjM1OTU5WiJ9XX0='
      expect(value['base64_policy']).to eq(p)
    end
  end
end
