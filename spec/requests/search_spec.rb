require 'rails_helper'

describe 'Search' do
  describe 'GET /search' do
    it 'shows the search form' do
      get '/search'
      expect(response.status).to eq(200)
      expect(response.body).to include('name="q[name_cont]"')
    end

    it 'shows the slides that match the words' do
      create(:slide, name: 'Sushi Talk')
      create(:slide, name: 'Ramen Talk')
      get '/search', params: { q: { name_cont: 'Sushi' } }
      expect(response.body).to include('Sushi Talk')
      expect(response.body).not_to include('Ramen Talk')
    end

    describe 'conditions that are not on the form' do
      let!(:mine) { create(:slide, name: 'Sushi Talk', user: create(:default_user)) }
      let!(:theirs) { create(:slide, name: 'Ramen Talk', user: create(:another_user)) }

      def found_names(conditions)
        get '/search', params: { q: conditions }
        Nokogiri::HTML(response.body).css('article.slidecard .slidecard-title a').map(&:text)
      end

      it 'can search by the name of the author' do
        expect(found_names(user_display_name_cont: 'User01')).to eq(['Sushi Talk'])
      end

      # 投稿者のメールアドレスや管理者かどうかで絞り込めると、1 文字ずつ試して当てられてしまう
      it 'ignores the e-mail address and the role of the author' do
        expect(found_names(user_email_start: 'user01')).to contain_exactly('Sushi Talk', 'Ramen Talk')
        expect(found_names(user_email_start: 'zzz')).to contain_exactly('Sushi Talk', 'Ramen Talk')
        expect(found_names(user_admin_eq: true)).to contain_exactly('Sushi Talk', 'Ramen Talk')
      end

      it 'ignores the columns that are not shown' do
        expect(found_names(object_key_eq: mine.object_key)).to contain_exactly('Sushi Talk', 'Ramen Talk')
        expect(found_names(user_id_eq: theirs.user_id)).to contain_exactly('Sushi Talk', 'Ramen Talk')
      end
    end
  end
end
