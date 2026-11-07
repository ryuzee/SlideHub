# ほかのサイトの JavaScript から読めるようにする（API と、埋め込み用の JavaScript）
module CrossOriginAccess
  extend ActiveSupport::Concern

  class_methods do
    # 引数は after_action と同じ（only: など）
    def allow_cross_origin_access(**)
      after_action :add_cross_origin_headers, **
    end
  end

  private

    def add_cross_origin_headers
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'GET'
    end
end
