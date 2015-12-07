describe 'Slides' do
  describe 'GET /slides' do
    it 'works!' do
      get '/slides'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/popular' do
    it 'works!' do
      get '/slides/popular'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/latest' do
    it 'works!' do
      get '/slides/latest'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/search' do
    it 'works!' do
      get '/slides/search'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/1' do
    it 'works!' do
      create_list(:slide, 2)
      get '/slides/1'
      expect(response.status).to eq(200)
    end
  end
end
