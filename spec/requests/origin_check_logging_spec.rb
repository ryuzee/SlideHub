require 'rails_helper'

# Origin ヘッダーの確認を有効にする前の下調べ（OriginCheckLogging）。
# 食い違いはログに残すだけで、送信そのものは弾かない
describe 'Origin check logging' do
  let(:user) { create(:default_user) }
  let(:slide) { create(:slide) }

  before do
    sign_in user
    allow(Rails.logger).to receive(:warn).and_call_original
  end

  def post_comment(origin)
    headers = origin ? { 'Origin' => origin } : {}
    post '/comments', params: { comment: { slide_id: slide.id, comment: 'Nice' } }, headers: headers
  end

  it 'logs a post from another origin without rejecting it' do
    expect { post_comment('https://other.example.com') }.to change(Comment, :count).by(1)
    expect(Rails.logger).to have_received(:warn).with(%r{\[OriginCheck\] Origin "https://other.example.com"})
  end

  it 'logs the headers the proxy passed, to see how to fix the mismatch' do
    post '/comments', params: { comment: { slide_id: slide.id, comment: 'Nice' } },
                      headers: { 'Origin' => 'https://slides.example.com', 'X-Forwarded-Host' => 'slides.example.com' }
    expect(Rails.logger).to have_received(:warn).with(/X-Forwarded-Host="slides.example.com"/)
  end

  it 'does not log a post from this site' do
    post_comment('http://www.example.com')
    expect(Rails.logger).not_to have_received(:warn).with(/\[OriginCheck\]/)
  end

  it 'does not log a post without the Origin header' do
    post_comment(nil)
    expect(Rails.logger).not_to have_received(:warn).with(/\[OriginCheck\]/)
  end
end
